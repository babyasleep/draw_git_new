;;*************************************************
;; calculate SPB intensity using the method in Jin et al 2021 by shuheng Lin 2021.06.16
;; we need to calculate ACF (autocorrlation function) firstly 
;; then calculate the gradient of ACF and then find the maximum ACF decline location 
;; more detailed can be found in Jin et al 2019,GRL
;;*************************************************************

function acr_cal(data,data2)  ;;  data:two dimension 12×yearnum array i.e.12×10
;;data1 : the monsoon anomous year  data2: next year
begin 
  dim = dimsizes(data)
  yearnum = dim(1)
  ;;; cal ACF, want to get a two dimensional array 12×13,initial month start June 
     acr = new((/12,13/),float)
     do i=0,11
         do j=0,12
            k=i+j 
            if k.le.11 then 
              acr(i,j) = escorc(data(i,0:yearnum-1),data(i+j,0:yearnum-1))
            else 
              acr(i,j) = escorc(data(i,0:yearnum-1),data2(i+j-12,0:yearnum-1))
            end if 
         end do 
     end do
return acr
end 


;Method1 uses Liu,2019 and count all year gradient.
;Method2 sums the graident given two month's gradient (maybe it is a test).
;Method3 averages the maximum of the gradient from April to June. 
function spb_cal(acr,method)
begin
   
   if method.eq.1 then 
   ;;method1 
   acr_gra = center_finite_diff_n(acr, 1, False, 1, 1)
   acr_gra = -1*acr_gra  ;;;change to positive
   acr_gra_max = dim_max_n(acr_gra, 1) 
   spb =  dim_sum_n_Wrap(acr_gra_max, 0)
   end if

   if method.eq.2 then 
   ;;method2  3-6月梯度
    acr_gra = acr(:,1) ;;give a 12 month dimension_sizes

    acr_gra(7) = (acr(7,2) - acr(7,5))/3  ;;3月-6月 7是对应1月
    acr_gra(8) = (acr(8,1) - acr(8,4))/3            ;;2月   次年3月-6月
    acr_gra(9) = (acr(9,0) - acr(9,3))/3               ;;3月   次年3月-6月
    acr_gra(10) = (acr(10,0) - acr(10,2))/2            ;;4月   次年4月-6月  
    acr_gra(11) = (acr(11,11) - acr(11,12))/1            ;;5月  次年4月-5月
    
    ;;;June is the first month, so 3 in (11-5-i+3) means March, 6 in (11-5-i+6) means June, count (March - June)'s gradient.
    do i =0,6
     acr_gra(i) = (acr(i,11-5-i+3) - acr(i,11-5-i+6))/2
    end do 
    spb =  dim_sum_n_Wrap(acr_gra, 0)
   end if

   ;;;June is the first month, so 4 in (11-5-i+4) means May, 6 in (11-5-i+6) means June.
   if method.eq.3 then 
   ;;;method3 
      acr_gra = center_finite_diff_n(acr, 1, False, 1, 1)
      acr_gra = -1*acr_gra  ;;;change to positive

      acr_gra_max = acr_gra(:,1)

      do i=0,9
      acr_gra_max(i) = dim_max_n(acr_gra(i,11-5-i+4:11-5-i+6), 0)
      end do 

      acr_gra_max(10) = dim_max_n(acr_gra(10,0:2), 0)           ;;4月      
      acr_gra_max(11) = dim_max_n(acr_gra(10,11:12), 0)

      spb =  dim_sum_n_Wrap(acr_gra_max, 0)
    end if
 return spb
 end 
;;;;
;;*************************************************
;; main program 
;;*************************************************************
begin
    startmon = 197901
    endmon = 201912

    startyear = tointeger(startmon/100)
    endyear = tointeger(endmon/100)
;;;;

;;;读入HadiSST海温数据
    diri="/home/yangsong3/Extension/linshh/data/sst/"
    fils1=systemfunc("ls "+diri+"HadISST_sst.nc")
    f1=addfile(fils1, "r")
    date:=cd_calendar(f1->time, 1)
    lat = f1->latitude
    lon = f1->longitude

    timeind:=ind(date.le.endmon.and.date.ge.startmon)

    sst=lonFlip(f1->sst(timeind,:,:))
    ; printVarSummary(sst)
    
    ssta=(/rmMonAnnCycTLL(sst)/)
    copy_VarCoords(sst, ssta)

    ;;detrend 
    ssta = (/dtrend_msg_n(ispan(1,dimsizes(ssta&time),1),ssta,False,True,0)/)
    copy_VarCoords(sst, ssta)
    ;;;
    delete(date)
    delete(timeind)
    
    nino34 =  dim_avg_n_Wrap(ssta(:,{5:-5},{190:240}), (/1,2/))
;;;

;;;split to 12 month nino34_12 is a array size (12,yearnum) monsoon year 
    yearnum = dimsizes(nino34)/12 -1
    ;yearnum = dimsizes(nino34)/12
    nino34_12 = new((/12,yearnum/),float)
;;;;


;;;;;;;;convert first year 1900 June -1901 May
  do i=0,11   
    if i.le.6 then 
     nino34_12(i,:) = nino34(i+5:dimsizes(nino34)-1-12:12)
     else
     nino34_12(i,:) = nino34(i+5:dimsizes(nino34)-1:12)   ;;;;first year 1900 June -1901 May
    end if
  end do 
  
  ;do i=0,11
  ;  nino34_12(i,:) = nino34(i:dimsizes(nino34)-1:12)
  ;end do
;;;;

dim = dimsizes(nino34_12)


;;; total year SPB
  acr_total = acr_cal(nino34_12(:,0:dim(1)-2), nino34_12(:,1:dim(1)-1))
  spb_total = spb_cal(acr_total,1)
  print(spb_total)
;;;


;;; cal Every year
spb_year = new(yearnum,float)

ind_all1 = ispan(0, yearnum-1, 1)  
ind_all2 = ispan(0, yearnum-2, 1)  ;;;remain the last year 

ind_all1@_FillValue =  99
ind_all2@_FillValue =  99

spb_year@_FillValue = nino34_12@_FillValue


do i=0,yearnum-1,1

  if i.ne.yearnum-1 then 
    indx = get1Dindex_Exclude(ind_all2, i)    ;;;去掉某一年数据 For non-last year, we remove the index in the short series ind_all2
  else 
    indx = get1Dindex_Exclude(ind_all1, i)    ;;;去掉某一年数据 For the last year, we remove the index in the long series ind_all1 (contained the last year)  
  end if 
  data1 = nino34_12(:,indx)
  data2 = nino34_12(:,indx+1)
  acr = acr_cal(data1,data2)
  spb_year(i) = spb_cal(acr,1)
  spb_year(i) = (/spb_total - spb_year(i)/)
  delete(indx)
  delete(acr)
  delete(data1)
  delete(data2)
end do


;-----count fisher z transform result-----------------------------
  acr_z_transform = acr_total
  ;write_matrix(acr_z_transform,"12f8.5",False)

  print("start counting acr_z_transform_total")
  do i=0,11,1
    do j=0,12,1
        if acr_total(i,j) .ne. 1 then
            acr_z_transform(i,j) = 0.5*log((1+acr_total(i,j))/(1-acr_total(i,j)))
        end if
    end do
  end do
  
  
  spb_z_transform = spb_cal(acr_z_transform,1)
  spb_z_transform = (exp(2*spb_z_transform)-1)/(exp(2*spb_z_transform)+1)
  print(spb_z_transform)

spb_year_z = new(yearnum,float)
do i=0,yearnum-1,1

  if i.ne.yearnum-1 then 
    indx = get1Dindex_Exclude(ind_all2, i)    ;;;去掉某一年数据 For non-last year, we remove the index in the short series ind_all2
  else 
    indx = get1Dindex_Exclude(ind_all1, i)    ;;;去掉某一年数据 For the last year, we remove the index in the long series ind_all1 (contained the last year)  
  end if 
  data1 = nino34_12(:,indx)
  data2 = nino34_12(:,indx+1)
  acr = acr_cal(data1,data2)
  
  acr_z = acr

  print("start counting acr_z_transform_year for the "+i+" time")
  do i_z=0,11
    do j_z=0,12
        if acr(i_z,j_z) .ne. 1 then
            acr_z(i_z,j_z) = 0.5*log((1+acr(i_z,j_z)/(1-acr(i_z,j_z))))
        end if
    end do
  end do
  
  spb_year_z(i) = spb_cal(acr_z,1)
  spb_year_z(i) = (exp(2*spb_year_z(i))-1)/(exp(2*spb_year_z(i))+1)
  spb_year_z(i) = (/spb_z_transform - spb_year_z(i)/)
  delete(indx)
  delete(acr)
  delete(data1)
  delete(data2)
end do



spb = dim_standardize(spb_year, 0)
copy_VarMeta(spb_year, spb)

spb_z = dim_standardize(spb_year_z, 0)
copy_VarMeta(spb_year_z, spb_z)
print(spb)
print(spb_z)
print("cov="+ escorc(spb,spb_z))

spb_z!0 = "year"
spb_z&year = ispan(startmon/100+1,endmon/100,1) ;;can not count the spb of first year of data because we miss the first MAM.

;print(spb_year)
;print(spb)
;print(spb_total)

;========================Calculates an unweighted running average =========================
run_num = 11
spb_ave =  runave(spb_z,run_num,0) 
spb_ave_std = dim_standardize_n_Wrap(spb_ave,0,0)
spb_ave_std_float = new(yearnum-run_num+1,float)

;match the spb_series to the specified year and abondon some serires at the beginning or at least.
;for the new series, year represent the center of the running average year. 
do i=0,yearnum-run_num
    spb_ave_std_float(i) = spb_ave_std(i+run_num/2)
end do

spb_ave_std_float!0 = "filter_central_11year"
spb_ave_std_float&filter_central_11year = ispan(startmon/100+run_num/2+1,endmon/100-run_num/2,1)
print(spb_ave_std_float)

;=====================output data =========================================================
output_file = "/home/ys17-23/cjx/all_output_data/monsoon/z_SPB_filter_"+startmon+"_"+endmon+".nc"
system("rm -rf "+output_file)
f2 = addfile(output_file, "c")
f2->SPB_filter = spb_ave_std_float
f2->SPB_z = spb_z
;;;;


;opt1="/home/ys17-23/lsh/Project/monsoon-ENSO/Springbarrier/interannual/SPB_index_interannual_1980-2019_method1.ascii"    
;asciiwrite(opt1, sprintf("%6.2f,",spb_year))  
;exit()
end 


   
