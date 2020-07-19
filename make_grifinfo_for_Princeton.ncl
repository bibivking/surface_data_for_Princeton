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
begin

file_name1 = "/srv/ccrc/data25/z5218916/script/reproduce_gridfile/gridinfo_mmy_MD_elev_orig_std_avg-sand_landmask.nc"
file_name2 = "gridinfo_mmy_MD_elev_orig_std_avg-sand_AU-Princeton_landmask.nc"

; ______________________________ Forming nc data ____________________________
fcp = addfile (file_name1,"r")
filo = file_name2

system("/bin/rm -f " + filo)    ; remove if exists
fout  = addfile (filo, "c")     ; open output file

; explicitly declare file definition mode. Improve efficiency.
setfileoption(fout,"DefineMode",True)

; create global attributes of the file
fAtt               = True            ; assign file attributes
fAtt@title         = "landmask file for gridinfo_mmy to run with Princeton data"
fAtt@source_file   = file_name1
fAtt@Conventions   = "None"
fAtt@creation_date = systemfunc ("date")
fileattdef( fout, fAtt )            ; copy file attributes

; predefine the coordinate variables and their dimensionality
; Note: to get an UNLIMITED record dimension, we set the dimensionality
; to -1 (or the actual size) and set the dimension name to True.

nlat   = 180 ;
nlon   = 360

dimNames = (/ "latitude", "longitude" /)
dimSizes = (/ nlat , nlon  /)
dimUnlim = (/ False, False /)
filedimdef(fout,dimNames,dimSizes,dimUnlim)

; predefine the the dimensionality of the variables to be written out
print("Predefine")
filevardef(fout, "landsea",typeof(fcp->landsea),getvardims(fcp->landsea))
filevardef(fout, "latitude",typeof(fcp->latitude),getvardims(fcp->latitude))
filevardef(fout, "longitude",typeof(fcp->longitude),getvardims(fcp->longitude))

print("Copy attributes")
filevarattdef(fout,"landsea",fcp->landsea)
filevarattdef(fout,"latitude",fcp->latitude)
filevarattdef(fout,"longitude",fcp->longitude)
setfileoption(fout,"DefineMode",False)
print("Exit DefineMode")

fout->latitude  = fspan(-89.5,89.5,180)
fout->longitude = fspan(0.5,359.5,360)
; print(fcp->longitude)
; print(fcp->latitude)
print(fout->longitude)
print(fout->latitude)
fout->landsea   = linint2(fcp->longitude,fcp->latitude,fcp->landsea,True,fout->longitude,fout->latitude,0)

end
