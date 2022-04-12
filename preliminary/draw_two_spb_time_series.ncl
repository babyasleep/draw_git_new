load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

psig = 0.05
; ==============================================================
; Open the file: Read only the user specified period
; ==============================================================
; ================================== 
startmon = 197901
endmon = 201912
path = "/home/ys17-23/cjx/all_output_data/monsoon/"
f1 = addfile(path+"SPB_decadal_"+startmon+"_"+endmon+".nc", "r")
  SPB_decadal  = f1->SPB_decadal(1:)
  printVarSummary(SPB_decadal)
; ================================== 
  f2 = addfile(path+"SPB_filter_"+startmon+"_"+endmon+".nc", "r")
  SPB_filter = f2->SPB_filter 
  SPB_origin = f2->SPB_origin
  printVarSummary(SPB_origin)
  cov = escorc(SPB_decadal, SPB_filter)
  print(cov)
; ================================== 
  f3 = addfile(path+"nino.nc","r")
  nino_DJF = f3->nino
  cov_nino = escorc(nino_DJF,SPB_origin)
  print(cov_nino)
  year_filter_start = min(SPB_decadal&central_time_11years)
  year_filter_end = max(SPB_decadal&central_time_11years)
  year_origin_start = min(SPB_origin&year)
  year_origin_end = max(SPB_origin&year)
; ===================================

outfile = "/home/ys17-23/cjx/figure/monsoon/draw_two_spb_time_series"
wks = gsn_open_wks("pdf",outfile)
nplot = 2
plot = new(nplot, graphic)
titles = (/"(a) Interannual SPB Index Time Series & Nino3.4",\
           "(b) Interannual SPB Index (11 Year Smooth) & Interdecadal SPB Index"/)

;--line setting-------------------------------------------  
  rts           = True
  rts@gsnDraw   = False       ; don't draw yet
  rts@gsnFrame  = False       ; don't advance frame yet
  rts@gsnScale  = True        ; force text scaling               
  rts@tmXTLabelsOn   = False
  rts@tmXTOn = False
  rts@tmYRLabelsOn   = False
  rts@tmYROn = False
  rts@tmYLMode = "Manual"
  rts@tmYLTickSpacingF = 1.0

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

  rts@vpHeightF = 0.18        ; Changes the aspect ratio
  rts@vpWidthF  = 0.52
  ;rts@vpXF      = (/0.11,0.78/)        ; change start locations
  ;rts@vpYF      = 0.95        ; the plot

  rts@tmXBLabelFontHeightF = 0.012;0.03
  rts@tmYLLabelFontHeightF = 0.012;0.03

  ;rts@tmXBTickSpacingF     = 5
;--Turn off X axis tickmarks
  rts@tmXBMajorLengthF         = 0.005;0.01
  rts@tmXBMajorOutwardLengthF  = 0.005;0.01  
  rts@tmYLMajorLengthF         = 0.005;0.01
  rts@tmYLMajorOutwardLengthF  = 0.005;0.01
  rts@tmXBMinorLengthF         = 0.0025;0.005
  rts@tmXBMinorOutwardLengthF  = 0.0025;0.005  
  rts@tmYLMinorLengthF         = 0.0025;0.005
  rts@tmYLMinorOutwardLengthF  = 0.0025;0.005 

  rts@tmXBLabelDeltaF      = -0.6
  rts@tmYLLabelDeltaF      = -0.6

  rts@trXMinF  = year_origin_start
  rts@trXMaxF  = year_origin_end

  rts@tiYAxisString = ""                   ; y-axis label      

  ;rts@gsnYRefLine           = 0.              ; reference line 

;----------------- bar0 chart resource -------------------------------
  rts0 = rts   
  ;rts0@xyMarkLineModes       = (/"MarkLines"/)
  rts0@xyDashPattern         = 0        
  rts0@xyLineColor           = "black"
  rts0@xyLineThicknessF      = "5"           
  rts0@trYMinF  = -2.5                   ; min value on y-axis
  rts0@trYMaxF  =  4.5   
  rts0@tmYLMode = "Explicit"
  rts0@tmYLLabels = (/-2,-1,0,1,2,3,4/)
;----------------- bar1 chart resource -------------------------------
  rts1 = rts   
  ;rts1@xyMarkLineModes       = (/"MarkLines"/)
  rts1@xyDashPattern         = 0       
  rts1@xyLineColor           = "black"
  rts1@xyLineThicknessF      = "6"           
  ;rts1@xyMarker              = 16 
  ;rts1@xyMarkerColor         = "red3"  
  ;rts1@xyMarkerSizes         = 0.02 
    
;----------------- bar2 chart resource -------------------------------
  rts2 = rts   
  ;rts2@xyMarkLineModes       = (/"MarkLines"/)
  rts2@xyDashPattern         = 12        
  rts2@xyLineColor           = "red3"
  rts2@xyLineThicknessF      = "3"           
  rts2@trYMinF  = -2.0                   ; min value on y-axis
  rts2@trYMaxF  =  2.5   
  ;rts2@xyMarker              = 16 
  ;rts2@xyMarkerColor         = "red3"  
  ;rts2@xyMarkerSizes         = 0.02 

;--------- draw 0 line -----------------------------------
  lon_line1 = (/year_origin_start,year_origin_end/)
  lat_line1 = (/0,0/)

  lnres                   = True
  lnres@gsLineColor       = "black" ;"purple" ;"chartreuse3"
  lnres@gsLineThicknessF  = 1.0
  lnres@gsLineDashPattern = 1
  lnres@gsLineOpacityF    = 0.5
    
  ;lon_line2 = (/year_filter_start,year_filter_end/)
  lon_line2 = lon_line1 
  lat_line2 = (/0,0/)

;--------------------------------------------------------
  year1 = ispan(year_origin_start,year_origin_end,1)
  year2 = ispan(year_filter_start,year_filter_end,1)
  dum = new(2,graphic)
  dum_line = new(4,graphic)
  dum_text = new(4,graphic)
;--------------------------------------------------------

; create the first plot
     rts0@gsnLeftString  = titles(0)
     rts0@gsnLeftStringFontHeightF  = 0.012
     rts0@gsnLeftStringOrthogonalPosF = -0.00
     rts0@gsnRightStringFontHeightF = 0.018
     plot(0) = gsn_csm_xy (wks,year1,SPB_origin,rts0)
     bar2 = gsn_csm_xy (wks,year1,nino_DJF,rts2)
     overlay(plot(0),bar2)
     ;overlay(plot(n), bar2)
    
    dum(0) = gsn_add_polyline(wks, plot(0), lon_line1, lat_line1, lnres)

; create the second plot
     rts1@gsnLeftString  = titles(1)
     rts1@gsnLeftStringFontHeightF  = 0.012
     rts0@gsnLeftStringOrthogonalPosF = 0.02
     rts1@gsnRightStringFontHeightF = 0.018
     plot(1) = gsn_csm_xy (wks,year2,SPB_decadal,rts2)
     bar = gsn_csm_xy (wks,year2,SPB_filter,rts1)
     overlay(plot(1), bar)
    
    dum(1) = gsn_add_polyline(wks, plot(1), lon_line2, lat_line2, lnres)

    ;--------------------------------------------------------
     res_text                    = True                  ; text mods desired
     res_text@txFontHeightF      = 0.012                 ; change text size
     res_text@txJust             = "CenterLeft"          ; text justification

     res_lines                   = True                  ; polyline mods desired
     res_lines@gsLineDashPattern = 0.                    ; solid line
     res_lines@gsLineThicknessF  = 3.5                    ; line thicker
     res_lines@gsLineColor       = "black"                 ; line color 

    ;----setting for the figure a---------------------------------
     res_text_cor = res_text
     res_text_cor@txPerimOn = True

     yy_0 = 4.0
     xx_center_0 = year_origin_end-6.2
     dum_cor = gsn_add_text(wks,plot(0),"Cor:"+sprintf("%6.2f", cov_nino),xx_center_0,yy_0,res_text_cor)
     
     yy_1 = yy_0
     xx_center_1 = year_origin_start+3.5 
     xx_1 = (/year_origin_start+1,year_origin_start+3.5/)
     yy = (/yy_1,yy_1/)
     dum_line(2) = gsn_add_polyline(wks,plot(0),xx_1,yy,res_lines)              ; add polyline
     dum_text(2) = gsn_add_text(wks,plot(0),"  SPB",xx_center_1,yy_1,res_text); add text
    ;--------------------------------------
     yy_2 = yy_1-0.7
     xx_center_2 = xx_center_1;2014.5
     xx_2 = xx_1;(/2012,2014/)
     yy = (/yy_2,yy_2/)
     res_lines@gsLineColor       = "red3"                                 ; change to red3
     res_lines@gsLineDashPattern       = 12.                                 ; change to red3
     dum_line(3) = gsn_add_polyline(wks,plot(0),xx_2,yy,res_lines)                ; add polyline
     dum_text(3) = gsn_add_text(wks,plot(0),"  Nino",xx_center_2,yy_2,res_text)       ; add text
    ;;--------------------------------------

    ;----setting for the figure b---------------------------------
     res_text_cor = res_text
     res_text_cor@txPerimOn = True

     yy_0 = 2.2
     xx_center_0 = year_origin_end-6.2
     dum_cor = gsn_add_text(wks,plot(1),"Cor:"+sprintf("%6.2f", cov),xx_center_0,yy_0,res_text_cor)
     
     yy_1 = 2.2
     xx_center_1 = year_origin_start+3.5 
     xx_1 = (/year_origin_start+1,year_origin_start+3.5/)
     yy = (/yy_1,yy_1/)
     res_lines@gsLineColor       = "black"                 ; line color 
     dum_line(0) = gsn_add_polyline(wks,plot(1),xx_1,yy,res_lines)              ; add polyline
     dum_text(0) = gsn_add_text(wks,plot(1),"  SPB_filter",xx_center_1,yy_1,res_text); add text
    ;--------------------------------------
     yy_2 = yy_1-0.7
     xx_center_2 = xx_center_1;2014.5
     xx_2 = xx_1;(/2012,2014/)
     yy = (/yy_2,yy_2/)
     res_lines@gsLineColor       = "red3"                                 ; change to red3
     res_lines@gsLineDashPattern       = 12.                                 ; change to red3
     dum_line(1) = gsn_add_polyline(wks,plot(1),xx_2,yy,res_lines)                ; add polyline
     dum_text(1) = gsn_add_text(wks,plot(1),"  SPB_decadal",xx_center_2,yy_2,res_text)       ; add text
    ;;--------------------------------------

;------------panel setting-------------------------------
resP                     = True         ; modify the panel plot
resP@gsnFrame            = False
;resP@gsnMaximize         = True         ; large format

resP@gsnPanelLabelBar    = False         ; add common colorbar
resP@lbLabelFontHeightF  = 0.013
;resP@pmLabelBarParallelPosF = -0.1
resP@pmLabelBarWidthF    = 0.7

resP@gsnPanelYWhiteSpacePercent  = 4.5

resP@gsnPanelMainString  = ""
;resP@gsnPanelMainString  = "TA SST ("+season+")"
resP@gsnPanelMainFontHeightF = 0.025
;resP@gsnPanelTop        = 0.735    ; only panel on lower half of page
;resP@gsnPanelXF         = (/0.10,0.52/)
resP@pmLabelBarWidthF   = 0.8    ; label bar width
;resP@gsnPanelBottom     = 0.25    ; space for label bar
;resP@gsnPanelTop        = 1.0    ; only panel on lower half of page
;resP@gsnPanelLeft        = 0.085
;resP@gsnPanelRight       = 0.92
gsn_panel(wks,plot,(/2,1/),resP)     ; now draw as one plot
frame(wks)
end
