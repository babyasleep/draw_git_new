
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

; ================================== 
f2 = addfile(path+"SPB_filter_"+startmon+"_"+endmon+".nc", "r")
SPB_origin = f2->SPB_origin
printVarSummary(SPB_origin)
; ================================== 
f3 = addfile(path+"nino.nc","r")
nino_DJF = f3->nino
nino_DJF = dim_standardize_n_Wrap(nino_DJF,0,0)
cov_nino = escorc(nino_DJF,SPB_origin)
print(cov_nino)
; ===================================

outfile = "/home/ys17-23/cjx/figure/monsoon/draw_scatter_spb_enso_type"
wks = gsn_open_wks("pdf",outfile)
plot = new(4, graphic)

labels = (/"EP_El","CP_El","LA_Nina","Normal"/)

EP_type = (/4,8,19,28,37/)
CP_type = (/1,9,13,16,24,26,31,36/)
LA_type = (/5,6,10,17,20,21,22,27,29,30,32,33,38/)
NO_type = (/0,2,3,7,11,12,14,15,18,23,25,34,35,39/)

SPB_EP_type = SPB_origin(EP_type)
nino_EP_type = nino_DJF(EP_type)

SPB_CP_type = SPB_origin(CP_type)
nino_CP_type = nino_DJF(CP_type)

SPB_LA_type = SPB_origin(LA_type)
nino_LA_type = nino_DJF(LA_type)

SPB_NO_type = SPB_origin(NO_type)
nino_NO_type = nino_DJF(NO_type)
;----------------------------------------------------------------------

;---Define the colors for the markers. white/black = background/foreground
colors = (/"red","orange","blue","black"/)

sizes = (/0.01,0.01,0.01,0.01/)

;--line setting-------------------------------------------  
rts           = True
rts@gsnDraw   = False       ; don't draw yet
rts@gsnFrame  = False       ; don't advance frame yet
rts@gsnScale  = True        ; force text scaling               
rts@tmXTLabelsOn   = False
rts@tmXTOn = False
rts@tmYRLabelsOn   = False
rts@tmYROn = False

; these four resources allow the user to stretch the plot size, and
; decide exactly where on the page to draw it.

rts@vpHeightF = 0.28        ; Changes the aspect ratio
rts@vpWidthF  = 0.52
;rts@vpXF      = (/0.11,0.78/)        ; change start locations
;rts@vpYF      = 0.95        ; the plot

rts@tmXBLabelFontHeightF = 0.012;0.03
rts@tmYLLabelFontHeightF = 0.012;0.03

thickness = 1.5
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
rts@tiXAxisFontThicknessF    = thickness
rts@tiYAxisFontThicknessF    = thickness
rts@tmXBLabelFontHeightF = 0.015
rts@tmYLLabelFontHeightF = 0.015
;rts@tmXBLabelDeltaF      = -0.6
;rts@tmYLLabelDeltaF      = -0.6

MaxF=2.0
rts@trXMinF  = MaxF*(-1.0) 
rts@trXMaxF  = MaxF 
rts@trYMinF  = MaxF*(-1.0) 
rts@trYMaxF  = MaxF 
rts@lgPerimOn              = True
rts@tiYAxisString = "SPB index"                   ; y-axis label      
rts@gsnLeftString = "Cov: "+ sprintf("%6.2f",cov_nino)
rts@gsnLeftStringOrthogonalPosF = -0.02
rts@tiXAxisString = "Nino 3.4"
rts@tiMainString = "Scatter SPB index & Nino 3.4"
rts@gsnYRefLine           = 0.              ; reference line 
rts@gsnXRefLine           = 0.              ; reference line 
rts@gsnXRefLineThicknessF = thickness
rts@gsnYRefLineThicknessF = thickness
rts@xyMarkLineMode     = "Markers"
rts@xyMarker = 16


rts@xyMarkerSizes = sizes(0)
rts@xyMarkerColors     = colors(0)   ; It's okay to list more than you need here
;plot(0)  = gsn_csm_xy (wks,nino_DJF,SPB_origin,rts)
plot(0)  = gsn_csm_xy (wks,nino_EP_type,SPB_EP_type,rts)

rts@xyMarkerSizes = sizes(1)
rts@xyMarkerColors     = colors(1)   ; It's okay to list more than you need here
plot(1)  = gsn_csm_xy (wks,nino_CP_type,SPB_CP_type,rts)

rts@xyMarkerSizes = sizes(2)
rts@xyMarkerColors     = colors(2)   ; It's okay to list more than you need here
plot(2)  = gsn_csm_xy (wks,nino_LA_type,SPB_LA_type,rts)

rts@xyMarkerSizes = sizes(3)
rts@xyMarkerColors     = colors(3)   ; It's okay to list more than you need here
plot(3)  = gsn_csm_xy (wks,nino_NO_type,SPB_NO_type,rts)


;--legend------------------------------------------------------
res_text                    = True                  ; text mods desired
res_text@txFontHeightF      = 0.012                 ; change text size
res_text@txJust             = "CenterLeft"          ; text justification

res_dot                   = True                  ; polyline mods desired
res_dot@gsMarkerIndex  = 16

x_gap = 0.3
y_gap = 0.3
yy_0 = MaxF-y_gap
xx_center_0 = MaxF*(-1.0)+x_gap

dum_dot = new(4, graphic)
dum_text = new(4, graphic)

res_dot@gsMarkerColor = colors(0)
res_dot@gsMarkerSizeF    = sizes(0)
dum_dot(0) = gsn_add_polymarker(wks, plot(0), xx_center_0-0.1, yy_0, res_dot)
dum_text(0) = gsn_add_text(wks,plot(0),labels(0),xx_center_0,yy_0,res_text); add text

yy_1 = yy_0-y_gap
xx_center_1 =  xx_center_0
res_dot@gsMarkerColor = colors(1)
res_dot@gsMarkerSizeF    = sizes(1)
dum_dot(1) = gsn_add_polymarker(wks, plot(1), xx_center_1-0.1, yy_1, res_dot)
dum_text(1) = gsn_add_text(wks,plot(1),labels(1),xx_center_1,yy_1,res_text); add text

yy_2 = yy_1-y_gap
xx_center_2 =  xx_center_1
res_dot@gsMarkerColor = colors(2)
res_dot@gsMarkerSizeF    = sizes(2)
dum_dot(2) = gsn_add_polymarker(wks, plot(2), xx_center_2-0.1, yy_2, res_dot)
dum_text(2) = gsn_add_text(wks,plot(2),labels(2),xx_center_2,yy_2,res_text); add text

yy_3 = yy_2-y_gap
xx_center_3 =  xx_center_2
res_dot@gsMarkerColor = colors(3)
res_dot@gsMarkerSizeF    = sizes(3)
dum_dot(3) = gsn_add_polymarker(wks, plot(3), xx_center_3-0.1, yy_3, res_dot)
dum_text(3) = gsn_add_text(wks,plot(3),labels(3),xx_center_3,yy_3,res_text); add text

;;;--------------------------------------

overlay(plot(0),plot(1))
overlay(plot(0),plot(2))
overlay(plot(0),plot(3))
draw(plot(0))
frame(wks)
end 
