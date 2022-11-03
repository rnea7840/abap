report ztcode.

parameters: month type dats default sy-datum obligatory,
            user  type usr02-bname obligatory default sy-uname.

types: begin of zusertcode,
         operation type char30,
         type      type char10,
         count     type swncshcnt,
       end of zusertcode.

types: tt_zusertcode type standard table of zusertcode with key operation type.

data: lt_usertcode type swnc_t_aggusertcode,
      ls_result    type zusertcode,
      lt_result    type tt_zusertcode.

constants: cv_tcode  type char30 value 'Tcode',
           cv_report type char30 value 'Report',
           cv_count  type char5 value 'Count'.

start-of-selection.

  call function 'SWNC_COLLECTOR_GET_AGGREGATES'
    exporting
      component     = 'TOTAL'
      periodtype    = 'M'
      periodstrt    = month
    tables
      usertcode     = lt_usertcode
    exceptions
      no_data_found = 1
      others        = 2.

  delete lt_usertcode where tasktype <> '01'.

  loop at lt_usertcode assigning field-symbol(<user>) where account = user.
    clear: ls_result.
    ls_result-operation = <user>-entry_id.
    ls_result-type = <user>-entry_id+72.
    ls_result-count = <user>-count.
    collect ls_result into lt_result.
  endloop.

  sort lt_result by count descending.

  write:  10 cv_tcode, 20 cv_report, 60 cv_count color col_negative.
  loop at lt_result assigning field-symbol(<result>).
    if <result>-type = 'T'.
      write: / <result>-operation color col_total under cv_tcode,
               <result>-count color col_positive under cv_count.
    else.
      write: / <result>-operation color col_group under cv_report,
               <result>-count color col_positive under cv_count.
    endif.
  endloop.