#! /usr/bin/python3
import csv
import operator
import pathlib
import sqlite3
from typing import Any, List
import urllib.request
import zipfile

DB_FILE = pathlib.Path('SR-Leg.db')
SCHEMA_FILE = pathlib.Path('schema.sql')
USDA_URL = 'https://www.ars.usda.gov/ARSUserFiles/80400525/Data/SR-Legacy/SR-Leg_ASC.zip'
ZIP_DB = pathlib.Path('SR-Leg_ASC.zip')

csv.register_dialect('usda', delimiter='^', quotechar='~')

SQL_TO_PYTHON = {
    ('TEXT', 1): str,
    ('INTEGER', 1): int,
    ('REAL', 1): float,
    ('TEXT', 0): lambda obj: str(obj) if obj else None,
    ('INTEGER', 0): lambda obj: int(obj) if obj else None,
    ('REAL', 0): lambda obj: float(obj) if obj else None,
}

def download_zip_db():
    with urllib.request.urlopen(USDA_URL) as response:
        ZIP_DB.write_bytes(response.read())


def create_empty_db() -> sqlite3.Connection:
    if DB_FILE.exists():
        raise RuntimeError('La base de datos ya existe y no puede ser creada.')
    conn = sqlite3.connect(DB_FILE)
    conn.row_factory = sqlite3.Row
    with open(SCHEMA_FILE) as file:
        schema_script = file.read()
    conn.executescript(schema_script)
    return conn


def get_table_names(conn: sqlite3.Connection) -> List[str]:
    return list(map(
        operator.itemgetter(0),
        conn.execute(
            """
            SELECT tbl_name
            FROM sqlite_master
            WHERE "type" LIKE 'table'
            """)))

def read_raw_table(table_name: str) -> List[List[str]]:
    with zipfile.ZipFile(ZIP_DB) as zipped_db:
        with zipped_db.open(table_name + '.txt') as file:
            raw_data = file.read()
    data = raw_data.decode('latin1').splitlines()
    return list(csv.reader(data, dialect='usda'))

def typefy_table(conn: sqlite3.Connection,
        table_name: str, raw_table: List[List[str]]) -> List[List[Any]]:
    cursor = list(conn.execute(f'pragma table_info({table_name})'))
    converters = [SQL_TO_PYTHON[row['type'], row['notnull']] for row in cursor]
    return [tuple(f(x) for (f, x) in zip(converters, row)) for row in raw_table]


def main():
    if not ZIP_DB.exists():
        print(f'No se encontró la base de datos {ZIP_DB}, descargando...')
        download_zip_db()

    print('Creando base de datos vacía...')
    conn = create_empty_db()
    table_names = get_table_names(conn)
    for table_name in table_names:
        print(f'Extrayendo el contenido a la tabla {table_name}...')
        raw_table = read_raw_table(table_name)
        values = typefy_table(conn, table_name, raw_table)

        print(f'Agregando el contenido de la tabla {table_name} a {DB_FILE}...')
        placeholders = ', '.join(['?']*len(values[0]))
        with conn:
            conn.executemany(
                f"""
                INSERT INTO {table_name}
                VALUES ({placeholders})
                """,
                values)

    print('Guardando los cambios en la base de datos...')
    conn.close()
    print('Terminado.')

if __name__ == '__main__':
    main()