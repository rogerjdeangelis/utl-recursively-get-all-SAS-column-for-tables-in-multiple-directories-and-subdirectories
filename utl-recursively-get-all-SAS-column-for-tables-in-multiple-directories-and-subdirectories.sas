Recursively get all SAS column for tables in multiple directories and subdirectories

Using concatenated paths was much more complex;
libname paths ("d:/parent" "d:/parent/child1" "d:/parent/child2");

StackOverflow
https://tinyurl.com/y5hjh2n6
https://stackoverflow.com/questions/56997440/how-do-i-get-all-columns-name-from-a-directory-and-sudirectories-including-pat

github directory utilities
https://tinyurl.com/yaajbg36
https://github.com/rogerjdeangelis/utl_file_and_directory_utilities_for_all_operating_systems

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

* create directories and subdiretories and populate each with at least two tables;
libname parent "d:/parent";
libname child1 "d:/parent/child1";
libname child2 "d:/parent/child2";

 data _null_;

     * create directories;
     if _n_=0 then do;
         %let rc=%sysfunc(dosubl('
            data _null_;
                rc=dcreate("parent","d:/");
                rc=dcreate("child1","d:/parent");
                rc=dcreate("child2","d:/parent");
            run;quit;
        '));
     end;

     * populate directories;
     length tbls $44;
       do tbls =  "parent.cars","parent.heart","child1.iris","child1.baseball","child2.iris","child2.zipcode";
           call symputx('ref',scan(tbls,1,"."));
           call symputx('tbl',scan(tbls,2,"."));
           rc=dosubl('
               data &ref..&tbl;
                  set sashelp.&tbl;
               run;quit;
           ');
       end;

run;quit;

libname parent clear;
libname child1 clear;
libname child2 clear;

 D:\PARENT
   |
   +  cars.sas7bdat
   +  heart.sas7bdat
   |
   +---child1
       |
       +-----iris.sas7bdat
       +-----baseball.sas7bdat
   |
   +---child2
       |
       +---iris.sas7bdat
       +---zipcode.sas7bdat


 *            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

              MEMBER                  VARIABLE

d:/parent/heart.sas7bdat              AGEATDEATH
d:/parent/heart.sas7bdat              AGEATSTART
d:/parent/heart.sas7bdat              AGECHDDIAG
....                                  ...
d:/parent/heart.sas7bdat              STATUS
d:/parent/heart.sas7bdat              SYSTOLIC
d:/parent/heart.sas7bdat              WEIGHT
d:/parent/heart.sas7bdat              WEIGHT_STATUS


d:/parent/child1/baseball.sas7bdat    CRATBAT
d:/parent/child1/baseball.sas7bdat    CRBB
d:/parent/child1/baseball.sas7bdat    CRHITS
...                                   ...
d:/parent/child1/baseball.sas7bdat    SALARY
d:/parent/child1/baseball.sas7bdat    TEAM
d:/parent/child1/baseball.sas7bdat    YRMAJOR


d:/parent/child1/iris.sas7bdat        PETALLENGTH
d:/parent/child1/iris.sas7bdat        PETALWIDTH
d:/parent/child1/iris.sas7bdat        SEPALLENGTH
d:/parent/child1/iris.sas7bdat        SEPALWIDTH
d:/parent/child1/iris.sas7bdat        SPECIES


d:/parent/child2/iris.sas7bdat        PETALLENGTH
d:/parent/child2/iris.sas7bdat        PETALWIDTH
d:/parent/child2/iris.sas7bdat        SEPALLENGTH
d:/parent/child2/iris.sas7bdat        SEPALWIDTH
d:/parent/child2/iris.sas7bdat        SPECIES


d:/parent/child2/zipcode.sas7bdat     ALIAS_CITY
d:/parent/child2/zipcode.sas7bdat     ALIAS_CITY
d:/parent/child2/zipcode.sas7bdat     AREACODE
...                                   ...
d:/parent/child2/zipcode.sas7bdat     Y
d:/parent/child2/zipcode.sas7bdat     ZIP
d:/parent/child2/zipcode.sas7bdat    ZIP_CLASS


*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __
/ __|/ _ \| | | | | __| |/ _ \| '_ \
\__ \ (_) | | |_| | |_| | (_) | | | |
|___/\___/|_|\__,_|\__|_|\___/|_| |_|

;

* you need to specify the parent folder after the cards4 statement, you can use d:/ for whole drive;

data dir;
  length root path $200 dir 8;
  call missing(path,dir);
  input root;
cards4;
d:/parent
;;;;
run;

data dir;
  modify dir;
  rc=filename('tmp',catx('/',root,path));
  dir=dopen('tmp');
  replace;
  if dir;
  path0=path;
  do _N_=1 to dnum(dir);
    path=catx('/',path0,dread(dir,_N_));
    output;
  end;
  rc=dclose(dir);
run;quit;

/*
Up to 40 obs WORK.DIR total obs=9

Obs      ROOT       PATH                        DIR

 1     d:/parent                                 1    Note 0 is lowest level with
 2     d:/parent    cars.sas7bdat                0    filenames
 3     d:/parent    child1                       1
 4     d:/parent    child2                       1
 5     d:/parent    heart.sas7bdat               0
 6     d:/parent    child1/baseball.sas7bdat     0
 7     d:/parent    child1/iris.sas7bdat         0
 8     d:/parent    child2/iris.sas7bdat         0
 9     d:/parent    child2/zipcode.sas7bdat      0
*/

data _null_;

  if _n_=0 then do; %let rc=%sysfunc(dosubl('
      proc datasets lib=work nolist;
          delete want;
      run;quit;
      '));
  end;

  set dir(where=(dir=0));

  fulpth=catx('/',root,path);

  call symputx("fulPth",fulPth);

  rc=dosubl('
      ods exclude all;
      ods output Variables=variables;
      proc contents data="&fulPth";
      run;quit;
      ods select all;
      data want;
         set want variables;
         keep member variable;
      run;quit;
  ');


run;quit;


