;;*************************************************
;; draw circulation pattern during monsoon year 
;;*******************************************************************

function  rc_test(ssta_rc)
begin
  tval = onedtond(ssta_rc@tval , dimsizes(ssta_rc))
   df   = onedtond(ssta_rc@nptxy, dimsizes(ssta_rc)) - 2
   b = tval    ; b must be same size as tval (and df)
   b = 0.5
   prob = betainc(df/(df+tval^2),df/2.0,b)    ; prob(nlat,nlon)
   copy_VarCoords(ssta_rc, prob)

return prob
end

;;;转换before和after 需要改变两个地方，一个是名字，另一个是计算方法部分
begin
    startmon = 197901
    endmon = 201912
    startyear = tointeger(startmon/100)
    endyear = tointeger(endmon/100)

;;;读入HadiSST海温数据,去掉长期趋势和annual cycle.
    diri="/home/ys17-23/Extension/GPCP/"
    fils1=systemfunc("ls "+diri+"precip.mon.mean.nc")
    f1=addfile(fils1, "r")
    date:=cd_calendar(f1->time, 1)
    lat = f1->lat
    lon = f1->lon

    timeind:=ind(date.le.endmon.and.date.ge.startmon)  ;;; 1979-2019

    sst=f1->precip(timeind,:,:)
    printVarSummary(sst)
    
    ssta=(/rmMonAnnCycTLL(sst)/)
    copy_VarCoords(sst, ssta)

    ;;detrend 
    ssta = (/dtrend_msg_n(ispan(1,dimsizes(ssta&time),1),ssta,False,True,0)/)
    ;;;
    delete(date)
    delete(timeind)
    
;;;


;;;读入ERA wind data,去掉长期趋势和annual cycle.

    fils1 = "/home/yangsong3/Extension/ERA5-monthly/pressure/u_mon_1x1_1979_2020.nc"
    ; fils1 = "/home/yangsong3/Extension/20thCRV2/uwnd.mon.mean.nc"
    f1 = addfile(fils1, "r")
    time1 = f1->time
    date1=cd_calendar(time1, 1)
    timeind1=ind(date1.ge.startmon.and.date1.le.endmon)  

 
;;;;U,V

    u_200  = short2flt(f1->u(timeind1,{200},:,:))
    u_850  = short2flt(f1->u(timeind1,{850},:,:))

    ; u_200  = f1->uwnd(timeind1,{200},:,:)
    ; u_850  = f1->uwnd(timeind1,{850},:,:)

    u_850 = (/rmMonAnnCycTLL(u_850)/)
    u_200 = (/rmMonAnnCycTLL(u_200)/)
;;;


;;;
    ; fils2 = "/home/yangsong3/Extension/20thCRV2/vwnd.mon.mean.nc"
    fils2  = "/home/yangsong3/Extension/ERA5-monthly/pressure/v_mon_1x1_1979_2020.nc"
    f2 = addfile(fils2, "r")
    time2 = f2->time
    date2 = cd_calendar(time2, 1)

    timeind2 = ind(date2.ge.startmon.and.date2.le.endmon)  ;;;风场数据从1979年开始

;;;;U,V

    ; v_200  = f2->vwnd(timeind1,{200},:,:)
    ; v_850  = f2->vwnd(timeind1,{850},:,:)

    ; v_850 = (/rmMonAnnCycTLL(v_850)/)
    ; v_200 = (/rmMonAnnCycTLL(v_200)/)
    v_200  = short2flt(f2->v(timeind2,{200},:,:))
    v_850  = short2flt(f2->v(timeind2,{850},:,:))

    v_850 = (/rmMonAnnCycTLL(v_850)/)
    v_200 = (/rmMonAnnCycTLL(v_200)/)

    u_850 = (/dtrend_msg_n(ispan(1,dimsizes(u_850&time),1),u_850,False,True,0)/)
    v_850 = (/dtrend_msg_n(ispan(1,dimsizes(v_850&time),1),v_850,False,True,0)/)
    u_200 = (/dtrend_msg_n(ispan(1,dimsizes(u_200&time),1),u_200,False,True,0)/)
    v_200 = (/dtrend_msg_n(ispan(1,dimsizes(v_200&time),1),v_200,False,True,0)/)
;;; modify the variable directly so that they do not need to copy variable meta.
;;; end reading uv and sst data

;; read the counted SPB data
    ;opt1="/home/ys17-23/lsh/Project/monsoon-ENSO/Springbarrier/interannual/SPB_index_interannual_1980-2019_method1.ascii" 
    ;spb_year = asciiread(opt1, -1, "float")  ;;1980-2019 ;;;
    input_file = "/home/ys17-23/cjx/all_output_data/monsoon/SPB_filter_197901_201912.nc"
    f_input = addfile(input_file,"r")
    spb_year = f_input->SPB_origin


  plot = new(12,graphic)
  iplot = plot
  str = ispan(1,12,1) + ""

  outfile = "/home/ys17-23/cjx/figure/monsoon/"
  wks = gsn_open_wks("pdf", outfile+"UVPRECIP_regression-SPB-before")
  month = (/"Jun(-1)","Jul(-1)","Aug(-1)","Sep(-1)","Oct(-1)","Nov(-1)","Dec(-1)","Jan","Feb","Mar","Apr","May"/) 

  ; wks = gsn_open_wks("pdf", outfile+"UVPRECIP_regression-SPB-after")
  ;month = (/"Jun","Jul","Aug","Sep","Oct","Nov","Dec","Jan(+1)","Feb(+1)","Mar(+1)","Apr(+1)","May(+1)"/) 

;start count the result for each month
do i=0,11

;;; 计算before  
;;; i=0对应是6月，提取1979年到2018年的6月（对于6月-12月做类似的处理）
    if i.le.6 then 
       ssta_month =  ssta(i+5:dimsizes(ssta&time)-1-12:12,:,:)
       u_200_month = u_200(i+5:dimsizes(u_200&time)-1-12:12,:,:)
       v_200_month = v_200(i+5:dimsizes(v_200&time)-1-12:12,:,:)
;;; i=7对应是1月，提取把1980年到2019年的1月（对1月-6月做类似的处理）
     else
       ssta_month =  ssta(i+5:dimsizes(ssta&time)-1:12,:,:)
       u_200_month = u_200(i+5:dimsizes(u_200&time)-1:12,:,:)
       v_200_month = v_200(i+5:dimsizes(v_200&time)-1:12,:,:)
     end if

     ssta_month_str = regCoef_n(spb_year, ssta_month, 0, 0)
     copy_VarCoords(ssta_month(0,:,:), ssta_month_str)

     u_month_str = regCoef_n(spb_year, u_200_month, 0, 0)
     copy_VarCoords(u_200_month(0,:,:), u_month_str)
   
     v_month_str = regCoef_n(spb_year, v_200_month, 0, 0)
     copy_VarCoords(v_200_month(0,:,:), v_month_str)
    
   
   ;;;;;计算after
   ;  if i.le.6 then 
   ;   ssta_month =  ssta(i+5+12:dimsizes(ssta&time)-1-12:12,:,:) ;5是为了跟计算SPB同步，12是后一年
   ;   u_200_month = u_200(i+5+12:dimsizes(u_200&time)-1-12:12,:,:)
   ;   v_200_month = v_200(i+5+12:dimsizes(v_200&time)-1-12:12,:,:)
   ; else
   ;   ssta_month =  ssta(i+5+12:dimsizes(ssta&time)-1:12,:,:)
   ;   u_200_month = u_200(i+5+12:dimsizes(u_200&time)-1:12,:,:)
   ;   v_200_month = v_200(i+5+12:dimsizes(v_200&time)-1:12,:,:)
   ; end if
   
   ;;;only count 1980-2018 spb and 1981-2019 wind and sst
   ; ssta_month_str = regCoef_n(spb_year(0:dimsizes(spb_year)-2), ssta_month, 0, 0)
   ; copy_VarCoords(ssta_month(0,:,:), ssta_month_str)

   ; u_month_str = regCoef_n(spb_year(0:dimsizes(spb_year)-2), u_200_month, 0, 0)
   ; copy_VarCoords(u_200_month(0,:,:), u_month_str)
   ; 
   ; v_month_str = regCoef_n(spb_year(0:dimsizes(spb_year)-2), v_200_month, 0, 0)
   ; copy_VarCoords(v_200_month(0,:,:), v_month_str)
    
; significant test 
    prob_sst_str = rc_test(ssta_month_str)
    prob_u_str = rc_test(u_month_str)
    prob_v_str = rc_test(v_month_str)

  
   sig_level = 0.05 
   ; ssta_month_str = where(prob_sst_str.le.sig_level, ssta_month_str, ssta_month_str@_FillValue)
   ; ssta_month_weak = where(prob_sst_weak.le.sig_level, ssta_month_weak, ssta_month_weak@_FillValue)
    u_month_str = where(prob_u_str.le.sig_level.or.prob_v_str.le.sig_level, u_month_str, u_month_str@_FillValue)
    v_month_str = where(prob_v_str.le.sig_level.or.prob_u_str.le.sig_level, v_month_str, v_month_str@_FillValue)


  

  
;;**************************************************************
;画图
;;***************************************************************

  res=True
  res@gsnFrame=False
  res@gsnDraw=False

  res@cnFillPalette = "precip_diff_12lev"
  ; res@cnFillPalette = "temp_diff_18lev"

  res@cnFillOn=True
  res@cnLinesOn=False

  res@cnLineLabelsOn=False
  res@lbLabelBarOn=False
  res@lbOrientation="Vertical"

  res@mpLimitMode           = "LatLon"
  res@mpMinLatF             = -60
  res@mpMaxLatF             = 60
  res@mpMinLonF             = 0
  res@mpMaxLonF             = 360

  res@mpCenterLonF          = (res@mpMinLonF+res@mpMaxLonF)/2.0

  res@tmXTOn=False
  res@tmYROn=False
  res@tmXBOn=True
  res@tmYROn=False

  res@tmXBMode="Explicit"
  res@tmYLMode="Explicit"

   
  res@tmXBLabelFontHeightF=0.015
  res@tmYLLabelFontHeightF=0.015
  res@tmXBMajorThicknessF=1.0
  res@tmYLMajorThicknessF=1.0
  res@tmBorderThicknessF=1.0

  res@cnLevelSelectionMode = "ManualLevels"      ; set manual contour level
  res@cnMinLevelValF       =   -0.8
  res@cnMaxLevelValF       =   0.8
  res@cnLevelSpacingF      =  0.2

  ; res@cnMinLevelValF       =   -0.8
  ; res@cnMaxLevelValF       =   0.8
  ; res@cnLevelSpacingF      =  0.1

    res@cnFillColors = (/2,3,4,5,6,6,9,10,11,12/)
  ; res@cnLevelSelectionMode  = "ExplicitLevels" ; set manual contour levels
  ; ; res@cnFillColors= (/2,3,4,6,8,9,10,11,13/) - 2 
  ; ; res@cnLevels := (/-12,-9,-6,-3,3,6,9,12/)*0.01
  ; res@cnLevels := (/-20,-15,-10,-5,5,10,15,20/)*0.01
  ; res@cnInfoLabelOn = False
  
  res@gsnLeftString = "PRECIP&200UV " + month(i)
  res@gsnLeftStringFontHeightF = 0.02

  ; res@mpShapeMode = "FreeAspect"
  ; res@vpHeightF = 0.2
  ; res@vpWidthF = 0.7

  res@gsnScalarContour        = True

  ;;;;;;;LineArrow
  res@vcMinDistanceF           = 0.02           ; thin vectors
  res@vcMinMagnitudeF          =0.4
  res@vcRefMagnitudeF          = 6.0
  res@vcRefLengthF             = 0.1     ; define length of v
  ; res@vcRefAnnoOrthogonalPosF  = -1.0              ; move ref vector down -1.0在图的右上
  res@vcLineArrowThicknessF = 1.0
  ; res@vcLineArrowHeadMaxSizeF=0.008
  ; res@vcLineArrowHeadMinSizeF=0.008
  res@vcLineArrowHeadMaxSizeF = 0.013           ;change the vector line arrows
  res@vcLineArrowHeadMinSizeF = 0.006
    
    
    if i.eq.11 then 
      res@vcRefAnnoOn = True
      res@vcRefAnnoOrthogonalPosF = 0.4
    else 
      res@vcRefAnnoOn = False
    end if

  
  res@gsnRightString = "U,V,PRECIP regressed onto SPB index"
  plot(i) = gsn_csm_vector_scalar_map(wks,u_month_str, v_month_str, ssta_month_str, res)
 



   ;;;draw box 
    pgres=True
    pgres@gsLineColor="black"
    pgres@gsLineThicknessF=0.8
    pgres@gsLineDashPattern=0

    lat1 = -5
    lat2 = 5
    lon1 = 190
    lon2 = 240

    pgx_pool=(/lon1,lon2,lon2,lon1,lon1/)
    pgy_pool=(/lat1,lat1,lat2,lat2,lat1/)
   ;;;

   
   plot@$str(i)$ = gsn_add_polyline(wks, plot(i), pgx_pool, pgy_pool, pgres)
 

   ;;;打点
    res_pro=True
    res_pro@gsnAddCyclic = False
    res_pro@gsnDraw=False
    res_pro@gsnFrame=False
    res_pro@cnFillOn = True

    res_pro@cnLevelSelectionMode = "ExplicitLevels"
    res_pro@cnLevels = (/0,0.1/)
    res_pro@lbLabelBarOn = False
    res_pro@cnLinesOn=False
    ; res_pro@cnMonoLineColor =False
    ; res_pro@cnLineColors = ((/"Transparent","White","Transparent"/))

    res_pro@cnMonoFillPattern = True
    res_pro@cnFillPattern = 17
    res_pro@cnFillDotSizeF = 0.001
    res_pro@cnMonoFillColor = False
    res_pro@cnFillColors = (/"Transparent","black","Transparent"/)
    ; res_pro@cnLevels = ispan(-6,6,1)
    res_pro@cnLineLabelsOn=False
    res_pro@tmYRMode = "Automatic"
    res_pro@cnInfoLabelOn=False

    iplot(i) = gsn_csm_contour(wks,prob_sst_str,res_pro)
   
  
    overlay(plot(i), iplot(i))

delete(ssta_month_str)
delete(u_month_str)
delete(v_month_str)
end do
pres = True
pres@gsnPanelLabelBar  = True
pres@pmLabelBarOrthogonalPosF = 0.025

; pres@lbLabelStride=1
gsn_panel(wks, plot, (/4,3/), pres)


end
