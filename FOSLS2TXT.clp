             PGM        PARM(&P1)

             DCLF       FILE(QTEMP/QPRTSPLQDB) OPNID(WP)

     /*?     Set up variables                                       */

             DCL        VAR(&P1) TYPE(*CHAR) LEN(15)
             DCL        VAR(&JOB) TYPE(*CHAR) LEN(10)
             DCL        VAR(&JOBNO) TYPE(*CHAR) LEN(6)
             DCL        VAR(&SPLF) TYPE(*CHAR) LEN(10)
             DCL        VAR(&SPLFNBR) TYPE(*CHAR) LEN(4)
             DCL        VAR(&SPLFNB#) TYPE(*DEC) LEN(4 0)
             DCL        VAR(&USER) TYPE(*CHAR) LEN(10)
             DCL        VAR(&USRDTA) TYPE(*CHAR) LEN(10)
             DCL        VAR(&FORMTYPE) TYPE(*CHAR) LEN(10)
             DCL        VAR(&DATEMDY) TYPE(*CHAR) LEN(6)
             DCL        VAR(&DATEYMD) TYPE(*CHAR) LEN(6)
             DCL        VAR(&TIMELONG) TYPE(*CHAR) LEN(8)
             DCL        VAR(&TIMESHORT) TYPE(*CHAR) LEN(6)
             DCL        VAR(&LSCOUNT) TYPE(*DEC) LEN(2 0)
             DCL        VAR(&LSCNT) TYPE(*CHAR) LEN(2)
             DCL        VAR(&CMDVAR) TYPE(*CHAR) LEN(100)
             DCL        VAR(&ESCANLCNT) TYPE(*DEC) LEN(2 0)
             DCL        VAR(&ESCANLCHAR) TYPE(*CHAR) LEN(2)
             DCL        VAR(&WPCNT) TYPE(*DEC) LEN(2 0)
             DCL        VAR(&WPCHAR) TYPE(*CHAR) LEN(2)
             DCL        VAR(&OUTQ) TYPE(*CHAR) LEN(15)

             RTVSYSVAL  SYSVAL(QDATE) RTNVAR(&DATEMDY)
             CVTDAT     DATE(&DATEMDY) TOVAR(&DATEYMD) FROMFMT(*MDY) +
                          TOFMT(*YMD) TOSEP(*NONE)
             RTVSYSVAL  SYSVAL(QTIME) RTNVAR(&TIMELONG)
             CHGVAR     VAR(&TIMESHORT) VALUE((%SST(&TIMELONG 1 2)) *TCAT +
                          (%SST(&TIMELONG 4 2)) *TCAT (%SST(&TIMELONG 7 +
                          2)))
             CHGVAR     VAR(&LSCOUNT) VALUE(0)
             CHGVAR     VAR(&ESCANLCNT) VALUE(0)
             CHGVAR     VAR(&ESCANLCHAR) VALUE(&ESCANLCNT)
             CHGVAR     VAR(&WPCNT) VALUE(0)
             CHGVAR     VAR(&WPCHAR) VALUE(&WPCNT)
             CHGVAR     VAR(&OUTQ) VALUE(&P1)

     /*?     Get a list of spoolfiles on the output queue           */

             WRKOUTQ    OUTQ(QUSRSYS/TOFOS) OUTPUT(*PRINT)
             CRTPF      FILE(QTEMP/QPRTSPLQDB) RCDLEN(132) LVLCHK(*NO)
             MONMSG     MSGID(CPF7302)
             CPYSPLF    FILE(QPRTSPLQ) TOFILE(QTEMP/QPRTSPLQDB) +
                          SPLNBR(*LAST)
             DLTSPLF    FILE(QPRTSPLQ) SPLNBR(*LAST)

     /*?     Read through the list of spool files                   */
 LOOP:       RCVF       OPNID(WP)

             MONMSG     MSGID(CPF0864) EXEC(GOTO CMDLBL(ENDLOOP))

             CHGVAR     VAR(&USRDTA) VALUE(%SST(&WP_QPRTSPLQDB 24 10))
             MONMSG     MSGID(CPF0818) EXEC(GOTO CMDLBL(SKIP))
             CHGVAR     VAR(&SPLF) VALUE(%SST(&WP_QPRTSPLQDB 2 10))
             MONMSG     MSGID(CPF0818) EXEC(GOTO CMDLBL(SKIP))
             CHGVAR     VAR(&USER) VALUE(%SST(&WP_QPRTSPLQDB 13 10))
             MONMSG     MSGID(CPF0818) EXEC(GOTO CMDLBL(SKIP))
             CHGVAR     VAR(&FORMTYPE) VALUE(%SST(&WP_QPRTSPLQDB 55 10))
             MONMSG     MSGID(CPF0818) EXEC(GOTO CMDLBL(SKIP))
             CHGVAR     VAR(&SPLFNBR) VALUE(%SST(&WP_QPRTSPLQDB 75 4))
             MONMSG     MSGID(CPF0818) EXEC(GOTO CMDLBL(SKIP))
             CHGVAR     VAR(&JOB) VALUE(%SST(&WP_QPRTSPLQDB 84 10))
             MONMSG     MSGID(CPF0818) EXEC(GOTO CMDLBL(SKIP))
             CHGVAR     VAR(&JOBNO) VALUE(%SST(&WP_QPRTSPLQDB 95 6))
             MONMSG     MSGID(CPF0818) EXEC(GOTO CMDLBL(SKIP))
             CHGVAR     VAR(&SPLFNB#) VALUE(&SPLFNBR)
             MONMSG     MSGID(CPF0818) EXEC(GOTO CMDLBL(SKIP))


     /*      Copy flat file to IFS                                  */

     /*      WP Notices - Non-Latenotice                            */
             IF         COND((&USRDTA *EQ 'WP2102R') *AND (&FORMTYPE *NE +
                          '*STD')) THEN(DO)
                CHGVAR     VAR(&WPCNT) VALUE(&WPCNT + 1)
                CHGVAR     VAR(&WPCHAR) VALUE(&WPCNT)
                CPYSPLF    FILE(&SPLF) TOFILE(OPERUTIL/SPOOL133) +
                             JOB(&JOBNO/&USER/&JOB) SPLNBR(&SPLFNB#) +
                             MBROPT(*REPLACE) CTLCHAR(*FCFC)
                MONMSG     MSGID(CPF0001) EXEC(GOTO CMDLBL(SKIP))
                CPYTOSTMF  +
                             FROMMBR('/QSYS.LIB/OPERUTIL.LIB/SPOOL133.FILE/S+
                             POOL133.MBR') +
                             TOSTMF('/FOS/TOFOS/LSAMS/LSAMS-' *CAT +
                             &FORMTYPE *TCAT &WPCHAR *TCAT '_' *CAT +
                             &DATEYMD *TCAT &TIMESHORT *TCAT '.txt') +
                             STMFOPT(*NONE) CVTDTA(*AUTO) DBFCCSID(*FILE) +
                             STMFCCSID(*PCASCII)
                CHGSPLFA   FILE(&SPLF) JOB(&JOBNO/&USER/&JOB) +
                             SPLNBR(&SPLFNB#) OUTQ(QUSRSYS/NOTICESTMP)
                CHGVAR     VAR(&LSCOUNT) VALUE(&LSCOUNT + 1)
             ENDDO

     /*      WP Latenotice                                          */
             ELSE       CMD(IF COND((&SPLF *EQ 'LATENOTICE') *AND (&USRDTA +
                          *EQ 'WP2102R') *AND (&FORMTYPE *EQ '*STD')) +
                          THEN(DO))
                CPYSPLF    FILE(&SPLF) TOFILE(OPERUTIL/SPOOL133) +
                             JOB(&JOBNO/&USER/&JOB) SPLNBR(&SPLFNB#) +
                             MBROPT(*REPLACE) CTLCHAR(*FCFC)
                MONMSG     MSGID(CPF0001) EXEC(GOTO CMDLBL(SKIP))
                CPYTOSTMF  +
                             FROMMBR('/QSYS.LIB/OPERUTIL.LIB/SPOOL133.FILE/S+
                             POOL133.MBR') +
                             TOSTMF('/FOS/TOFOS/LSAMS/LSAMS-LATENOTICE_' +
                             *TCAT &DATEYMD *TCAT &TIMESHORT *TCAT '.txt') +
                             STMFOPT(*NONE) CVTDTA(*AUTO) DBFCCSID(*FILE) +
                             STMFCCSID(*PCASCII)
                CHGSPLFA   FILE(&SPLF) JOB(&JOBNO/&USER/&JOB) +
                             SPLNBR(&SPLFNB#) OUTQ(QUSRSYS/NOTICESTMP)
                CHGVAR     VAR(&LSCOUNT) VALUE(&LSCOUNT + 1)
             ENDDO

     /*      Late Letters/Mailers                                   */
             ELSE       CMD(IF COND((&SPLF *EQ 'MAILERS') *AND (&USRDTA +
                          *EQ 'JIK282R') *AND (&FORMTYPE *EQ 'MAILERS')) +
                          THEN(DO))
                CPYSPLF    FILE(&SPLF) TOFILE(OPERUTIL/SPOOL133) +
                             JOB(&JOBNO/&USER/&JOB) SPLNBR(&SPLFNB#) +
                             MBROPT(*REPLACE) CTLCHAR(*FCFC)
                MONMSG     MSGID(CPF0001) EXEC(GOTO CMDLBL(SKIP))
                CPYTOSTMF  +
                             FROMMBR('/QSYS.LIB/OPERUTIL.LIB/SPOOL133.FILE/S+
                             POOL133.MBR') +
                             TOSTMF('/FOS/TOFOS/LSAMS/LSAMS-MAILERS_' *CAT +
                             &DATEYMD *TCAT &TIMESHORT *TCAT '.txt') +
                             STMFOPT(*NONE) CVTDTA(*AUTO) DBFCCSID(*FILE) +
                             STMFCCSID(*PCASCII)
                CHGSPLFA   FILE(&SPLF) JOB(&JOBNO/&USER/&JOB) +
                             SPLNBR(&SPLFNB#) OUTQ(QUSRSYS/NOTICES)
                CHGVAR     VAR(&LSCOUNT) VALUE(&LSCOUNT + 1)
             ENDDO

     /*      Escrow Analysis Letters                                */
             ELSE       CMD(IF COND((&SPLF *EQ 'ESCANLLTR') *AND (&USRDTA +
                          *EQ 'SR212JR') *AND (&FORMTYPE *EQ 'LETR')) +
                          THEN(DO))
                CHGVAR     VAR(&ESCANLCNT) VALUE(&ESCANLCNT + 1)
                CHGVAR     VAR(&ESCANLCHAR) VALUE(&ESCANLCNT)
                CPYSPLF    FILE(&SPLF) TOFILE(OPERUTIL/SPOOL133) +
                             JOB(&JOBNO/&USER/&JOB) SPLNBR(&SPLFNB#) +
                             MBROPT(*REPLACE) CTLCHAR(*FCFC)
                MONMSG     MSGID(CPF0001) EXEC(GOTO CMDLBL(SKIP))
                CPYTOSTMF  +
                             FROMMBR('/QSYS.LIB/OPERUTIL.LIB/SPOOL133.FILE/S+
                             POOL133.MBR') +
                             TOSTMF('/FOS/TOFOS/LSAMS/LSAMS-ESCROWANALYSIS' +
                             *CAT &ESCANLCHAR *TCAT '_' *CAT &DATEYMD +
                             *TCAT &TIMESHORT *TCAT '.txt') STMFOPT(*NONE) +
                             CVTDTA(*AUTO) DBFCCSID(*FILE) +
                             STMFCCSID(*PCASCII)
                CHGSPLFA   FILE(&SPLF) JOB(&JOBNO/&USER/&JOB) +
                             SPLNBR(&SPLFNB#) OUTQ(QUSRSYS/NOTICESTMP)
                CHGVAR     VAR(&LSCOUNT) VALUE(&LSCOUNT + 1)
             ENDDO

     /*      FHA Letters                                            */
             ELSE       CMD(IF COND((&SPLF *EQ 'LETTER') *AND (&USRDTA *EQ +
                          'SR220LC') *AND (&FORMTYPE *EQ 'FHALETTE')) +
                          THEN(DO))
                CPYSPLF    FILE(&SPLF) TOFILE(OPERUTIL/SPOOL133) +
                             JOB(&JOBNO/&USER/&JOB) SPLNBR(&SPLFNB#) +
                             MBROPT(*REPLACE)
                MONMSG     MSGID(CPF0001) EXEC(GOTO CMDLBL(SKIP))
                CPYTOSTMF  +
                             FROMMBR('/QSYS.LIB/OPERUTIL.LIB/SPOOL133.FILE/S+
                             POOL133.MBR') +
                             TOSTMF('/FOS/TOFOS/LSTAXES/LSAMS-FHALETTER_' +
                             *CAT &DATEYMD *TCAT &TIMESHORT *TCAT '.txt') +
                             STMFOPT(*NONE) CVTDTA(*AUTO) DBFCCSID(*FILE) +
                             STMFCCSID(*PCASCII)
                CHGSPLFA   FILE(&SPLF) JOB(&JOBNO/&USER/&JOB) +
                             SPLNBR(&SPLFNB#) OUTQ(QUSRSYS/NOTICESTMP)
                CHGVAR     VAR(&LSCOUNT) VALUE(&LSCOUNT + 1)
             ENDDO

     /*      YE Corrected Tax Files                                 */
             ELSE       CMD(IF COND((&USRDTA *EQ 'SR99INTC1R') *AND +
                          (&FORMTYPE *EQ '1099INT') *AND (&SPLF *EQ +
                          'COR99INT')) THEN(DO))
                CPYSPLF    FILE(&SPLF) TOFILE(OPERUTIL/SPOOL133) +
                             JOB(&JOBNO/&USER/&JOB) SPLNBR(&SPLFNB#) +
                             MBROPT(*REPLACE)
                MONMSG     MSGID(CPF0001) EXEC(GOTO CMDLBL(SKIP))
                CPYTOSTMF  +
                             FROMMBR('/QSYS.LIB/OPERUTIL.LIB/SPOOL133.FILE/S+
                             POOL133.MBR') +
                             TOSTMF('/FOS/TOFOS/LSTAXES/LSAMS-' *CAT &SPLF +
                             *TCAT '_' *CAT DATEYMD *TCAT &TIMESHORT *TCAT +
                             '.txt') STMFOPT(*NONE) CVTDTA(*AUTO) +
                             DBFCCSID(*FILE) STMFCCSID(*PCASCII)
                CHGSPLFA   FILE(&SPLF) JOB(&JOBNO/&USER/&JOB) +
                             SPLNBR(&SPLFNB#) OUTQ(&OUTQ)
                CHGVAR     VAR(&LSCOUNT) VALUE(&LSCOUNT + 1)
             ENDDO

             GOTO       CMDLBL(SKIP)

 SKIP:
             GOTO       CMDLBL(LOOP)

 ENDLOOP:

     /*?     Delete the temporary file                               */
             DLTF       FILE(QTEMP/QPRTSPLQDB)

     /*      Create LSAMS Recon File                                */

             CLRPFM     FILE(OPERUTIL/SPOOL133)
             CPYTOSTMF  +
                          FROMMBR('/QSYS.LIB/OPERUTIL.LIB/SPOOL133.FILE/SPOO+
                          L133.MBR') +
                          TOSTMF('/FOS/TOFOS/LSAMS/LSAMS-RECON_' *CAT +
                          &DATEYMD *TCAT &TIMESHORT *TCAT '.txt') +
                          STMFOPT(*REPLACE) CVTDTA(*AUTO) DBFCCSID(*FILE) +
                          STMFCCSID(*PCASCII)
             CHGVAR     VAR(&LSCNT) VALUE(&LSCOUNT)
             CHGVAR     VAR(&CMDVAR) VALUE('ECHO' *BCAT &LSCNT *TCAT ' >> +
                          /FOS/TOFOS/LSAMS/LSAMS-RECON_' *CAT &DATEYMD +
                          *TCAT &TIMESHORT *TCAT '.txt')
             STRQSH     CMD(&CMDVAR)

             ENDPGM 