srcSourceCodeView
debImport "-top" "tb" "-f" "flist.f" "-2001"
srcResizeWindow 0 0 974 1039
srcViewImportLogFile
srcDeselectAll -win $_nTrace2
srcDeselectAll -win $_nTrace2
srcResizeWindow -7 0 1026 1039
debReload
srcHBSelect "sad_cal" -win $_nTrace1
srcSelect -win $_nTrace1 -range {1 1 3 4 1 1}
srcDeselectAll -win $_nTrace1
srcAction -pos 4 4 -cmdMessage -win $_nTrace1
srcDeselectAll -win $_nTrace2
srcSelect -win $_nTrace2 -range {12 12 1 19 1 1}
srcCreateWindow -file C:\Users\26802\Desktop\digital_ic\cal_sad\code\sad_model.v
srcGotoLine -win $_nTrace3 30
srcDeselectAll -win $_nTrace3
srcDeselectAll -win $_nTrace1
srcDeselectAll -win $_nTrace3
srcDeselectAll -win $_nTrace3
srcDeselectAll -win $_nTrace3
srcDeselectAll -win $_nTrace3
srcDeselectAll -win $_nTrace3
srcDeselectAll -win $_nTrace3
srcCloseWindow -win $_nTrace3
srcDeselectAll -win $_nTrace2
srcSelect -win $_nTrace2 -range {12 12 1 19 1 1}
srcCreateWindow -file C:\Users\26802\Desktop\digital_ic\cal_sad\code\sad_model.v
srcGotoLine -win $_nTrace4 30
srcDeselectAll -win $_nTrace4
srcSelect -win $_nTrace4 -range {30 32 1 1 1 1}
srcDeselectAll -win $_nTrace4
srcCloseWindow -win $_nTrace4
srcDeselectAll -win $_nTrace2
debReload
srcHBSelect "sad_cal" -win $_nTrace1
srcSelect -win $_nTrace1 -range {1 1 3 4 1 1}
srcDeselectAll -win $_nTrace2
srcDeselectAll -win $_nTrace2
srcSelect -win $_nTrace2 -range {12 12 16 17 2 1}
srcDeselectAll -win $_nTrace2
srcSelect -win $_nTrace2 -range {12 12 16 19 1 1}
srcDeselectAll -win $_nTrace2
srcSelect -win $_nTrace2 -range {11 12 5 1 1 1}
debReload
srcHBSelect "sad_cal" -win $_nTrace1
srcSelect -win $_nTrace1 -range {1 1 3 4 1 1}
srcCloseWindow -win $_nTrace2
debExit
