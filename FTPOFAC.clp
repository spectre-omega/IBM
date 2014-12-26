             PGM

             /* Declare variables */
             DCL        VAR(&OLDHASH) TYPE(*CHAR) LEN(33)
             DCL        VAR(&NEWHASH) TYPE(*CHAR) LEN(33)
             DCL        VAR(&CMDSTRING) TYPE(*CHAR) LEN(200)

             /* Retrieve MD5 hash of current OFAC file */
             RTVDTAARA  DTAARA(FSAUTO/OFACMD5OLD) RTNVAR(&OLDHASH)

             /* Download latest OFAC file from U.S. Treasury */
             CLRPFM     FILE(FSAUTO/QTXTSRC) MBR(FTPOFACLOG)
             OVRDBF     FILE(INPUT) TOFILE(FSAUTO/QTXTSRC) MBR(FTPOFAC)
             OVRDBF     FILE(OUTPUT) TOFILE(FSAUTO/QTXTSRC) MBR(FTPOFACLOG)
             STRTCPFTP  RMTSYS('ofacftp.treas.gov')
             DLTOVR     FILE(*ALL)

             /* Calculate MD5 hash of new OFAC file */
             CHGVAR     VAR(&CMDSTRING) VALUE('openssl md5 /ofac/sdall.zip +
                          | awk -F''= '' ''{print $2}'' | datarea -w +
                          /qsys.lib/fsauto.lib/ofacmd5new.dtaara')
             STRQSH     CMD(&CMDSTRING)
             RTVDTAARA  DTAARA(FSAUTO/OFACMD5NEW) RTNVAR(&NEWHASH)

             /* If new hash same as old hash, skip to end */
             IF         COND(&OLDHASH *EQ &NEWHASH) THEN(GOTO SKIP)

             /* Else */
             /* Extract contents of OFAC file to /OFAC */
             STRQSH     CMD('cd /OFAC && jar -xvf sdall.zip')

             /* Run Robot/REPLAY job to import OFAC files into Horizon */
             RBTRPYLIB/RPYEXECUTE NAME(OFACUPDATE)

             /* Set hash value of old hash to new hash */
             CHGDTAARA  DTAARA(FSAUTO/OFACMD5OLD) VALUE(&NEWHASH)

             /* Email OFACUPDATE group (BSA and Computer Ops) */
             RBTALRLIB/RBASNDMSG MSG('The OFAC database in Horizon has +
                          been updated with new information.') +
                          TOPG(OFACUPDATE) SUBJECT('OFAC Update for +
                          Horizon')

 SKIP:

             ENDPGM 