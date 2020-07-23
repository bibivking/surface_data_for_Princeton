;*******************************************
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;*******************************************

;______ From Mark Decker's code ______
setvalues NhlGetWorkspaceObjectId()
  "wsMaximumSize" : 5000000000 ;
end setvalues
;_____________________________________

; ================== Regriding Function ===============
undef("regrid_data")
function regrid_data(var,interp_method,lat2d,lon2d, LAT, LON, src_mask, dst_mask)
local var_regrid, Opt, var
begin

    Opt                   = True

    Opt@SrcFileName       = "WRF_SCRIP.nc"      ; Name of source and ???
    Opt@DstFileName       = "1degree.nc"    ; destination files  ???

    Opt@InterpMethod      = interp_method

    Opt@SrcRegional       = True
    Opt@SrcGridMask       = src_mask

    Opt@DstRegional       = True
    ; Opt@DstLLCorner       = (/ minlat,minlon /)
    ; Opt@DstURCorner       = (/ maxlat,maxlon /)
    Opt@DstGridType       = "rectilinear"
    Opt@DstGridLat        = LAT
    Opt@DstGridLon        = LON
    Opt@DstGridMask       = dst_mask

    Opt@ForceOverwrite    = True
    Opt@PrintTimings      = True
    Opt@Debug             = True

    var@lat2d = lat2d              ; This information will be used by
    var@lon2d = lon2d              ; ESMF_regrid for the source grid
    var_regrid = ESMF_regrid(var,Opt)     ; Do the regridding for TMP
    printVarSummary(var_regrid)
    delete(Opt)
    return(var_regrid)
end


; ================================ Main Program ================================

begin

fname_input = "/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_MD_elev_orig_std_avg-sand_mask.nc"
fname_lis   = "/srv/ccrc/data25/z5218916/script/surface_data_for_Princeton/nc_files/LIS/lis_input.d01.nc"
fname_mask  = "/srv/ccrc/data25/z5218916/script/surface_data_for_Princeton/nc_files/gridinfo_mmy_MD_elev_orig_std_avg-sand_AU-Princeton_landmask.nc"

fname_out  = "/srv/ccrc/data25/z5218916/script/surface_data_for_Princeton/nc_files/gridinfo_mmy_MD_elev_orig_std_avg-sand_AU-Princeton_mask_test.nc"
system("/bin/rm -f " + fname_out)    ; remove if exists

; _________________ option __________________
fin   = addfile (fname_input, "r")
flis  = addfile (fname_lis, "r")
fmask = addfile (fname_mask, "r")
fout  = addfile (fname_out, "c")

; _________________ set range of lat and lon ______________________
lat_s = -89.5
lat_e = 89.5
lon_s = 0.5
lon_e = 359.5

nlat   = 180
nlon   = 360
ntime  = 12
nsoil  = 6
npatch = 1
nrad   = 3
nsdepth = 6

; ======================== lat-lon =========================
Lon = fin->longitude
Lat = fin->latitude

lat  = fspan( lat_s, lat_e, nlat)
lon  = fspan( lon_s, lon_e, nlon)

; ======================== NETCDF ==========================
setfileoption(fout,"DefineMode",True)

fAtt               = True            ; assign file attributes
fAtt@title         = "CABLE global surface forcing data"
fAtt@source_file   = "gridinfo_mmy_MD_elev_orig_std_avg-sand_mask.nc & lis_input.d01.nc"

fAtt@Conventions   = "None"
fAtt@creation_date = systemfunc ("date")
fileattdef( fout, fAtt )            ; copy file attributes

dimNames = (/"time", "latitude", "longitude", "soil", "patch", "rad", "soil_depth"/)
dimSizes = (/ 12   ,  nlat     ,  nlon      ,  nsoil,  npatch,  nrad,  nsdepth    /)
dimUnlim = (/ False,  False    ,  False     ,  False,  False ,  False, False      /)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

; __________________ 1D ___________________
filevardef( fout, "time", "integer", "time")
fout->time  = (/1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12/)

filevardef( fout, "patch", "double", "patch")
fout->patch = 1.

filevardef( fout, "rad", "integer", "rad")
fout->rad   = (/1, 2, 3/)

filevardef( fout, "soil", "integer", "soil")
fout->soil  = (/1, 2, 3, 4, 5, 6/)

filevardef( fout, "soil_depth", "float", "soil_depth")
fout->soil_depth  = (/0.011, 0.051, 0.157, 0.4385, 1.1855, 3.164/)

filevardef( fout, "latitude", "float", "latitude")
fout->latitude    = fspan( lat_s, lat_e, nlat)

filevardef( fout, "longitude", "float", "longitude")
fout->longitude   = fspan( lon_s, lon_e, nlon)

; _________________ 2D ___________________
filevardef( fout, "iveg", "integer", (/ "latitude", "longitude" /))
filevardef( fout, "landsea", "float", (/ "latitude", "longitude" /))
filevardef( fout, "soil_color", "float", (/ "latitude", "longitude" /))
filevardef( fout, "Albedo", "float", (/ "latitude", "longitude" /)) ; three dims in CSIRO std
filevardef( fout, "albedo2", "float", (/ "latitude", "longitude" /))
filevardef( fout, "Sy", "float", (/ "latitude", "longitude" /))
filevardef( fout, "dtb", "float", (/ "latitude", "longitude" /))
filevardef( fout, "drainage_density", "float", (/ "latitude", "longitude" /))
;filevardef( fout, "drainage_dist", "float", (/ "latitude", "longitude" /)) ; this var is not used by CABLE
filevardef( fout, "slope", "float", (/ "latitude", "longitude" /))
filevardef( fout, "slope_std", "float", (/ "latitude", "longitude" /))
filevardef( fout, "elevation", "float", (/ "latitude", "longitude" /))
filevardef( fout, "elevation_std", "float", (/ "latitude", "longitude" /))
filevardef( fout, "permeability", "float", (/ "latitude", "longitude" /))
;filevardef( fout, "permeability_std", "float", (/ "latitude", "longitude" /)) ; this var is not used by CABLE

; Soil Parameters
filevardef( fout, "isoil", "integer", (/ "latitude", "longitude" /))
filevardef( fout, "rhosoil", "float", (/ "latitude", "longitude" /))
filevardef( fout, "sand", "float", (/ "latitude", "longitude" /))
filevardef( fout, "clay", "float", (/ "latitude", "longitude" /))
filevardef( fout, "silt", "float", (/ "latitude", "longitude" /))
filevardef( fout, "organic", "float", (/ "latitude", "longitude" /))
filevardef( fout, "bch", "float", (/ "latitude", "longitude" /))
filevardef( fout, "sucs", "float", (/ "latitude", "longitude" /))
filevardef( fout, "ssat", "float", (/ "latitude", "longitude" /))
filevardef( fout, "sfc", "float", (/ "latitude", "longitude" /))
filevardef( fout, "swilt", "float", (/ "latitude", "longitude" /))
filevardef( fout, "css", "float", (/ "latitude", "longitude" /))
filevardef( fout, "cnsd", "float", (/ "latitude", "longitude" /))
filevardef( fout, "hyds", "float", (/ "latitude", "longitude" /))

nml_2D = (/\
    "landsea", "soil_color", "Albedo", "albedo2",   \
    "Sy", "dtb", "drainage_density", "slope", "slope_std",  \
    "elevation", "elevation_std", "permeability",           \
    "rhosoil", "sand", "clay", "silt", "organic", "bch",\
    "sucs", "ssat", "sfc", "swilt", "css", "cnsd", "hyds" /)

do var_num = 0, dimsizes(nml_2D)-1
   print(nml_2D(var_num))
   fout->$nml_2D(var_num)$ = linint2(Lon,Lat,fin->$nml_2D(var_num)$,True,lon,lat,0)
end do

do x = 0, dimsizes(lat)-1
  do y = 0, dimsizes(lon)-1
    ;print(lat(x)+" "+lon(y))
    iveg_4 = fin->iveg({lat(x)-0.5:lat(x)+0.5},{lon(y)-0.5:lon(y)+0.5})
    ;print(dimsizes(iveg_4))
    fout->iveg(x,y) = iveg_4(0,0)
    delete(iveg_4)
  end do
end do

; Zobler soil type
sand = fout->sand
clay = fout->clay
silt = fout->silt
isoil = new((/nlat, nlon/),"integer")
isoil@_FillValue = -9999
sand@_FillValue = -9999
clay@_FillValue = -9999
silt@_FillValue = -9999
FV    = -9999
isoil = -9999

print("calculating isoil")
isoil = where((clay .lt. 0.23) .and. (sand .lt. 0.50)                        ,8 ,isoil)
isoil = where((clay .lt. 0.23) .and. (sand .gt. 0.50) .and. (sand .lt. 0.75) ,4 ,isoil)
isoil = where((clay .lt. 0.23) .and. (sand .ge. 0.75)                        ,1 ,isoil)
isoil = where((clay .ge. 0.23) .and. (clay .lt. 0.28) .and. (sand .lt. 0.45) ,8 ,isoil)
isoil = where((clay .ge. 0.23) .and. (clay .lt. 0.28) .and. (sand .ge. 0.45) ,7 ,isoil)
isoil = where((clay .ge. 0.28) .and. (clay .lt. 0.37) .and. (sand .lt. 0.20) ,2 ,isoil)
isoil = where((clay .ge. 0.28) .and. (clay .lt. 0.37) .and. (sand .ge. 0.20) .and. (sand .lt. 0.43),6 ,isoil)
isoil = where((clay .ge. 0.28) .and. (clay .lt. 0.37) .and. (sand .ge. 0.43) ,7 ,isoil)
isoil = where((clay .ge. 0.37) .and. (clay .lt. 0.41) .and. (sand .lt. 0.20) ,2 ,isoil)
isoil = where((clay .ge. 0.37) .and. (clay .lt. 0.41) .and. (sand .ge. 0.20) .and. (sand .lt. 0.43),6 ,isoil)
isoil = where((clay .ge. 0.37) .and. (clay .lt. 0.41) .and. (sand .ge. 0.43) ,5 ,isoil)
isoil = where((clay .ge. 0.41) .and. (sand .lt. 0.43)                        ,3 ,isoil)
isoil = where((clay .ge. 0.41) .and. (sand .ge. 0.43)                        ,5 ,isoil)
isoil = where((sand.lt.0) .or. (clay.lt.0) .or. (silt .lt. 0)                ,FV,isoil)

fout->isoil = isoil(:,:)*1
delete(isoil)
delete(sand)
delete(clay)
delete(silt)

;___________________ 3D ______________________
filevardef( fout, "patchfrac", "float", (/ "patch", "latitude", "longitude" /))
fout->patchfrac = 1.

filevardef( fout, "SnowDepth", "float", (/"time", "latitude", "longitude" /))
fout->SnowDepth = 0. ;read from CSIRO std, Mark's grid file is 0

filevardef( fout, "LAI", "float", (/"time", "latitude", "longitude" /))
fout->LAI = linint2(Lon,Lat,fin->LAI,True,lon,lat,0)

nml_3D = (/ "rhosoil_vec", "sand_vec", "clay_vec", "silt_vec", "org_vec", "bch_vec",\
            "sucs_vec", "ssat_vec", "sfc_vec", "swilt_vec", "css_vec", "cnsd_vec", \
            "hyds_vec", "watr" /)

do var_num = 0,dimsizes(nml_3D)-1
    print(nml_3D(var_num))
    filevardef(fout, nml_3D(var_num), "float", (/ "soil_depth", "latitude", "longitude" /))
    fout->$nml_3D(var_num)$ = linint2(Lon,Lat,fin->$nml_3D(var_num)$,True,lon,lat,0)
    fout->$nml_3D(var_num)$@_FillValue = -9999.
end do

; ___________________ 4D ______________________
filevardef( fout, "SoilMoist", "float", (/"time", "soil", "latitude", "longitude" /))
; the value in Mark's gridinfo is higher than CSIRO std and the variance is less than CSIRO std
; May need to run a 120 years simulation to get equibrilum soil moisture
filevardef( fout, "SoilTemp", "float", (/"time", "soil", "latitude", "longitude" /))
; Both gridinfo and CSIRO have value

nml_4D = (/"SoilMoist","SoilTemp"/)

do var_num = 0,1
   print(nml_4D(var_num))
   fout->$nml_4D(var_num)$ = linint2(Lon,Lat,fin->$nml_4D(var_num)$,True,lon,lat,0)
end do

; ================================== Regrid ====================================
interp_method = "neareststod"  ;"neareststod"; "conserve" "patch";"bilinear"

minlon  = 116.5 ;min(lon2d)-1 ; 116.5516
minlat  = -44.5 ;min(lat2d)-1 ; -44.43771
maxlon  = 154.5 ;max(lon2d)+1 ; 154.5981
maxlat  = -12.5 ;max(lat2d)+1 ; -12.5853

src_mask = where(.not.ismissing(flis->LAI(0,:,:)),1,0)
dst_mask = where(fmask->landsea({minlat:maxlat},{minlon:maxlon}) .eq. 0, 1,0)

lat2d    = flis->lat
lon2d    = flis->lon
lon2d    = where(lon2d.lt.0,360+lon2d,lon2d)

LAT      = fspan(minlat,maxlat,dimsizes(dst_mask(:,0)))
LON      = fspan(minlon,maxlon,dimsizes(dst_mask(0,:)))

; LAI
LAI_tmp = regrid_data(flis->LAI,interp_method, lat2d, lon2d, LAT, LON, src_mask, dst_mask )
fout->LAI(:,{minlat:maxlat},{minlon:maxlon}) = where(.not. isnan_ieee(LAI_tmp) , LAI_tmp, -9999.)*1.
printVarSummary(fout->LAI(:,{minlat:maxlat},{minlon:maxlon}))
delete(LAI_tmp)

; Albedo
Albedo_tmp = regrid_data(flis->ALBEDO(0,:,:),interp_method, lat2d, lon2d, LAT, LON, src_mask, dst_mask )
fout->Albedo({minlat:maxlat},{minlon:maxlon}) = where(.not. isnan_ieee(Albedo_tmp) , Albedo_tmp, -1.)*1.
printVarSummary(fout->Albedo({minlat:maxlat},{minlon:maxlon}))
delete(Albedo_tmp)

; ================================= Attributes =================================
    ; _____________________ 1D ________________________
    fout->time@units     = "months" ;
    fout->time@long_name = "time"

    fout->patch@units     = "patch fraction"
    fout->patch@long_name = "patch"

    fout->rad@long_name = "rad"

    fout->soil@units = "soil layers" ;
    fout->soil@long_name = "soil" ;

    fout->soil_depth@long_name     = "depth of the middle point in the soil layer"
    fout->soil_depth@units         = "m"
    fout->soil_depth@_FillValue    =  -9999.

    fout->latitude@long_name     = "latitude"
    fout->latitude@units         = "degrees_North"
    fout->latitude@_FillValue    =  -9999.

    fout->longitude@long_name     = "longitude"
    fout->longitude@units         = "degrees_East"
    fout->longitude@_FillValue    =  -9999.

    ; _____________________ 2D ________________________
    fout->iveg@long_name     = "CSIRO classification of veg type"
    fout->iveg@_FillValue    = -1

    fout->isoil@long_name   = "Zobler soil type";
    fout->isoil@_FillValue  = -9999

    fout->landsea@units      = "0:land, 1:sea";
    fout->landsea@_FillValue = -9999.

    fout->Albedo@long_name = "unknown sources" ;CSIRO std "ISLSCP2 snow-free bareground albedo";
    fout->Albedo@_FillValue = -1.0

    fout->albedo2@long_name = "unknown sources" ; CSIRO std "UM SNOW-FREE ALBEDO OF SOIL";
    fout->albedo2@_FillValue = -9999.

    ; "soil_color" information

    fout->Sy@long_name = "saturated water content of the aquifer (GWssat_vec)"
    fout->Sy@units = "m3/m3";
    fout->Sy@_FillValue = -9999.

    fout->dtb@long_name = "depth to bedrock";
    fout->dtb@units = "m";
    fout->dtb@_FillValue = -9999.

    fout->drainage_density@long_name = "drainage density"
    fout->drainage_density@units = "1/m";
    fout->drainage_density@_FillValue = -9999.
    fout->drainage_density@filling_method = "missing values north of 60N filled by linearly regressing against soil texture, slope, dtb, top ind, source area";

    fout->slope@long_name = "mean slope";
    fout->slope@units = "m/m";
    fout->slope@_FillValue = -9999.

    fout->slope_std@long_name = "stddev of slope"
    fout->slope_std@units = "m/m";
    fout->slope_std@_FillValue = -9999.

    fout->elevation@long_name = "elevation above sea level"
    fout->elevation@units = "m";
    fout->elevation@_FillValue = -9999.

    fout->elevation_std@long_name = "stddev of elevation"
    fout->elevation_std@units = "m";
    fout->elevation_std@_FillValue = -9999.

    fout->permeability@long_name     = "saturated hydraulic conductivity of the aquifer"
    fout->permeability@units         = "mm/s"; unconcord to "m2" in Mark's elve file
    fout->permeability@_FillValue = -9999.

    ; soil parameters
    fout->rhosoil@long_name = "Soil bulk density"
    fout->rhosoil@units     = "kg/m3"
    fout->rhosoil@_FillValue = -9999.

    fout->sand@long_name    = "Sand fraction"
    fout->sand@units        = "m3/m3"
    fout->sand@_FillValue   = -9999.

    fout->clay@long_name    = "Clay fraction"
    fout->clay@units        = "m3/m3"
    fout->clay@_FillValue   = -9999.

    fout->silt@long_name    = "Silt fraction"
    fout->silt@units        = "m3/m3"
    fout->silt@_FillValue   = -9999.

    fout->organic@long_name = "Organic carbon fraction"
    fout->organic@units     = "m3/m3"
    fout->organic@_FillValue= -9999.

    fout->hyds@long_name    = "saturated soil conductivity"
    fout->hyds@units        = "m/s"
    fout->hyds@_FillValue   = -9999.

    fout->bch@long_name     = "Clapp-Hornberger b coefficient"
    fout->bch@_FillValue    = -9999.

    fout->sucs@long_name    = "Saturated soil water suction"
    fout->sucs@units        = "m" ; check it with original equation
    fout->sucs@_FillValue   = -9999.

    fout->ssat@long_name    = "Volumetric soil moisture content at saturation"
    fout->ssat@units        = "m3/m3"
    fout->ssat@_FillValue   = -9999.

    fout->swilt@long_name   = "Volumetric soil moisture content at wilting point"
    fout->swilt@units       = "m3/m3"
    fout->swilt@_FillValue  = -9999.

    fout->sfc@long_name     = "Field capacity (volumetric soil moisture content at critical point)" ;
    fout->sfc@units         = "m3/m3"
    fout->sfc@_FillValue    = -9999.

    fout->css@long_name     = "Soil specific heat capacity" ;
    fout->css@units         = "J/kg/K" ;
    fout->css@_FillValue    = -9999.

    fout->cnsd@long_name    = "Thermal conductivity"
    fout->cnsd@units        = "W/m/K" ;
    fout->cnsd@_FillValue   = -9999.

    fout->isoil@long_name   = "Zobler soil type";
    fout->isoil@_FillValue  = -9999

    ; ____________________ 3D ________________________

    fout->patchfrac@long_name     = "Patch fraction" ; 1.0 for 1x1 grid
    fout->patchfrac@_FillValue    =  -9999.

    fout->SnowDepth@long_name     = "Actual depth of snow"
    fout->SnowDepth@units         = "m";
    fout->SnowDepth@_FillValue    = -1.0

    fout->LAI@long_name         = "Leaf area index"
    fout->LAI@_FillValue        = -9999. ; set -9999. because no missing value point in gridinfo

    fout->rhosoil_vec@long_name = "Soil bulk density"
    fout->rhosoil_vec@units     = "kg/m3"

    fout->sand_vec@long_name    = "Sand fraction"
    fout->sand_vec@units        = "m3/m3"

    fout->clay_vec@long_name    = "Clay fraction"
    fout->clay_vec@units        = "m3/m3"

    fout->silt_vec@long_name    = "Silt fraction"
    fout->silt_vec@units        = "m3/m3"

    fout->org_vec@long_name     = "Organic carbon fraction"
    fout->org_vec@units         = "m3/m3"

    fout->hyds_vec@long_name    = "saturated soil conductivity"
    fout->hyds_vec@units        = "mm/s"

    fout->bch_vec@long_name     = "Clapp-Hornberger b coefficient"

    fout->sucs_vec@long_name    = "Saturated soil water suction"
    fout->sucs_vec@units        = "m" ; check it with original equation

    fout->ssat_vec@long_name    = "Volumetric soil moisture content at saturation"
    fout->ssat_vec@units        = "m3/m3"

    fout->swilt_vec@long_name   = "Volumetric soil moisture content at wilting point"
    fout->swilt_vec@units       = "m3/m3"

    fout->sfc_vec@long_name     = "Field capacity (volumetric soil moisture content at critical point)" ;
    fout->sfc_vec@units         = "m3/m3"

    fout->css_vec@long_name     = "Soil specific heat capacity" ;
    fout->css_vec@units         = "J/kg/K" ;

    fout->cnsd_vec@long_name    = "Thermal conductivity"
    fout->cnsd_vec@units        = "W/m/K" ;

    fout->watr@long_name        = "Residual water content of the soil"
    fout->watr@units            = "m3/m3"

    ; ____________________ 4D ________________________
    fout->SoilMoist@long_name     = "Soil moisture profile from previous GSWP runs";
    fout->SoilMoist@units         = "m3/m3";
    fout->SoilMoist@_FillValue = -9999.

    fout->SoilTemp@long_name     = "Soil temperature profile from previous GSWP runs";
    fout->SoilTemp@units         = "K";
    fout->SoilTemp@_FillValue    = 9.96921e+36
    fout->SoilTemp               = where(ismissing(fout->SoilTemp), -9999., fout->SoilTemp)
    fout->SoilTemp@_FillValue    = -9999.

setfileoption(fout,"DefineMode",False)
print("Exit DefineMode")

end
