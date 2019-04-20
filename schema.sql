CREATE TABLE "FD_GROUP" (
    "FdGrp_Cd" TEXT NOT NULL,
    "FdGrp_Desc" TEXT NOT NULL,
    PRIMARY KEY ("FdGrp_Cd")
);
CREATE TABLE "NUTR_DEF" (
    "Nutr_No" TEXT NOT NULL,
    "Units" TEXT NOT NULL,
    "Tagname" TEXT,
    "NutrDesc" TEXT NOT NULL,
    "Num_Dec" TEXT NOT NULL,
    "SR_Order" INTEGER NOT NULL,
    PRIMARY KEY ("Nutr_No")
);
CREATE TABLE "SRC_CD" (
    "Src_Cd" TEXT NOT NULL,
    "SrcCd_Desc" TEXT NOT NULL,
    PRIMARY KEY ("Src_Cd")
);
CREATE TABLE "DERIV_CD" (
    "Deriv_Cd" TEXT NOT NULL,
    "Deriv_Desc" TEXT NOT NULL,
    PRIMARY KEY ("Deriv_Cd")
);
CREATE TABLE "DATA_SRC" (
    "DataSrc_ID" TEXT NOT NULL,
    "Authors" TEXT,
    "Title" TEXT NOT NULL,
    "Year" TEXT,
    "Journal" TEXT,
    "Vol_City" TEXT,
    "Issue_State" TEXT,
    "Start_Page" TEXT,
    "End_Page" TEXT,
    PRIMARY KEY ("DataSrc_ID")
);
CREATE TABLE "DATSRCLN" (
    "NDB_No" TEXT NOT NULL,
    "Nutr_No" TEXT NOT NULL,
    "DataSrc_ID" TEXT NOT NULL,
    PRIMARY KEY ("NDB_No", "Nutr_No", "DataSrc_ID"),
    FOREIGN KEY ("DataSrc_ID") REFERENCES "DATA_SRC" ("DataSrc_ID")
);
CREATE TABLE "NUT_DATA" (
    "NDB_No" TEXT NOT NULL,
    "Nutr_No" TEXT NOT NULL,
    "Nutr_Val" REAL NOT NULL,
    "Num_Data_Pts" REAL NOT NULL,
    "Std_Error" REAL,
    "Src_Cd" TEXT NOT NULL,
    "Deriv_Cd" TEXT,
    "Ref_NDB_No" TEXT,
    "Add_Nutr_Mark" TEXT,
    "Num_Studies" INTEGER,
    "Min" REAL,
    "Max" REAL,
    "DF" INTEGER,
    "Low_EB" REAL,
    "Up_EB" REAL,
    "Stat_cmt" TEXT,
    "AddMod_Date" TEXT,
    PRIMARY KEY ("NDB_No", "Nutr_No"),
    FOREIGN KEY ("NDB_No", "Nutr_No") REFERENCES "DATSRCLN" ("NDB_No", "Nutr_No"),
    FOREIGN KEY ("Src_Cd") REFERENCES "DATA_SRC" ("Src_Cd"),
    FOREIGN KEY ("Deriv_Cd") REFERENCES "DERIV_CD" ("Deriv_Cd")
);
CREATE TABLE "FOOTNOTE" (
    "NDB_No" TEXT NOT NULL,
    "Footnt_No" TEXT NOT NULL,
    "Footnt_Typ" TEXT NOT NULL,
    "Nutr_No" TEXT,
    "Footnt_Txt" TEXT NOT NULL,
    FOREIGN KEY ("Nutr_No") REFERENCES "NUT_DATA" ("Nutr_No")
);
CREATE TABLE "WEIGHT" (
    "NDB_No" TEXT NOT NULL,
    "Seq" TEXT NOT NULL,
    "Amount" REAL NOT NULL,
    "Msre_Desc" TEXT NOT NULL,
    "Gm_Wgt" REAL NOT NULL,
    "Num_Data_Pts" INTEGER,
    "Std_Dev" REAL,
    PRIMARY KEY ("NDB_No", "Seq")
);
CREATE TABLE "LANGDESC" (
    "Factor_Code" TEXT NOT NULL,
    "Description" TEXT NOT NULL,
    PRIMARY KEY ("Factor_Code")
);
CREATE TABLE "LANGUAL" (
    "NDB_No" TEXT NOT NULL,
    "Factor_Code" TEXT NOT NULL,
    PRIMARY KEY ("NDB_No", "Factor_Code"),
    FOREIGN KEY ("Factor_Code") REFERENCES "LANGDESC" ("Factor_Code")
);
CREATE TABLE "FOOD_DES" (
    "NDB_No" TEXT NOT NULL,
    "FdGrp_Cd" TEXT NOT NULL,
    "Long_Desc" TEXT NOT NULL,
    "Shrt_Desc" TEXT NOT NULL,
    "ComName" TEXT,
    "ManufacName" TEXT,
    "Survey" TEXT,
    "Ref_desc" TEXT,
    "Refuse" INTEGER,
    "SciName" TEXT,
    "N_Factor" REAL,
    "Pro_Factor" REAL,
    "Fat_Factor" REAL,
    "CHO_Factor" REAL,
    PRIMARY KEY ("NDB_No"),
    FOREIGN KEY ("FdGrp_Cd") REFERENCES "FD_GROUP" ("FdGrp_Cd"),
    FOREIGN KEY ("NDB_No") REFERENCES "NUT_DATA" ("NDB_No"),
    FOREIGN KEY ("NDB_No") REFERENCES "WEIGHT" ("NDB_No"),
    FOREIGN KEY ("NDB_No") REFERENCES "FOOTNOTE" ("NDB_No"),
    FOREIGN KEY ("NDB_No") REFERENCES "LANGUAL" ("NDB_No")
);