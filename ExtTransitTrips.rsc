
Macro "ExtTransitTrips" (Args)

  RunMacro("TCB Init")

// scenario input folder

	shared scen_data_dir = ("C:\\Users\\JacobFo\\TRMv6.2\\Vision\\Input\\")

// Input files

	extmatrixin = scen_data_dir + "Input\\Extp\\EE_EI-IE2050.mtx"

	extparam = scen_data_dir +"Input\\Parameters\\"

// Output files

  outdirectory = scen_data_dir+"Input\\Transit\\"

	interimdir = scen_data_dir+"Interim\\"

// Parameters

	numtaz = R2I(Args.[Number of Zones])        // Number of total zones to use for matrix size

// Check for the existence of the output matrices that are being created and delete them if they exist.
// This saves you having to manually go there and delete them every time you rerun the script.

chkExist = GetFileInfo(interimdir+"TRMv6_ExtTransit_Parameter1_Share_TransitAV.mtx")
if chkExist<> null then DeleteFile(interimdir+"TRMv6_ExtTransit_Parameter1_Share_TransitAV.mtx")

chkExist = GetFileInfo(interimdir+"TRMv6_ExtTransit_Parameter2_Share_TransitMode.mtx")
if chkExist<> null then DeleteFile(interimdir+"TRMv6_ExtTransit_Parameter2_Share_TransitMode.mtx")

chkExist = GetFileInfo(interimdir+"TRMv6_ExtTransit_Parameter3_Share_AttrTAZ.mtx")
if chkExist<> null then DeleteFile(interimdir+"TRMv6_ExtTransit_Parameter3_Share_AttrTAZ.mtx")

//------------------------------------------------------------------------------
//    Check for existing output matrices
//------------------------------------------------------------------------------
/*
chkExist = GetFileInfo("C:\\temp\\output\\2013\\ExtTransit_TotalEIAutoVehicleTrip_2013.mtx")
if chkExist<> null then DeleteFile("C:\\temp\\output\\2013\\ExtTransit_TotalEIAutoVehicleTrip_2013.mtx")

chkExist = GetFileInfo("C:\\temp\\output\\2013\\ExtTransit_TransitEIAutoVehicleTrip_2013.mtx")
if chkExist<> null then DeleteFile("C:\\temp\\output\\2013\\ExtTransit_TransitEIAutoVehicleTrip_2013.mtx")

chkExist = GetFileInfo("C:\\temp\\output\\2013\\ExtTransit_TransitPKOPMode_2013.mtx")
if chkExist<> null then DeleteFile("C:\\temp\\output\\2013\\ExtTransit_TransitPKOPMode_2013.mtx")

chkExist = GetFileInfo("C:\\temp\\output\\2013\\Transit_External_PK.mtx")
if chkExist<> null then DeleteFile("C:\\temp\\output\\2013\\Transit_External_PK.mtx")

chkExist = GetFileInfo("C:\\temp\\output\\2013\\Transit_External_OP.mtx")
if chkExist<> null then DeleteFile("C:\\temp\\output\\2013\\Transit_External_OP.mtx")
*/


//------------------------------------------------------------------------------
//          Step 0A - Create TransitAV matrix.
//------------------------------------------------------------------------------

shared d_matrix_options

Opts = null
Opts.[File Name] = interimdir + "TRMv6_ExtTransit_Parameter1_Share_TransitAV.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"oneTable"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True


m = CreateSimpleMatrix("TransitAV", numtaz, 1, Opts)

//open the matrix and fill with a default of 0

m = OpenMatrix(Opts.[File Name],)
mc0A = CreateMatrixCurrency(m, "oneTable",,,)
mc0A := 0

//------------------------------------------------------------------------------

//open a file and create a data vector from a column in that file, this vector will be used to fill the above matrix.

excel_file = extparam + "TRMv6_ExtTransit_Parameters.xlsx"

TransitAV_Table = OpenTable("AV", "EXCEL", {excel_file, "pctTransitAV$"}, {{"False", "False"}})
SetView(TransitAV_Table)

//Get values from Share_TransitAV field and import into a vector

v1 = GetDataVector(TransitAV_Table+"|", "Share_TransitAV", {{"Sort Order", {{"TAZ_TRMv6", "Ascending"}}}, , , , ,"True"})

CloseView(TransitAV_Table)

//Copy the values of Share_TransitAV into rows in the above matrix, each cell in a row will have the value of the vector in the corresponding row.

SetMatrixVector(mc0A, v1, {{"Col",1}})


//------------------------------------------------------------------------------
//          Step 0B - Create TransitMode matrix.
//------------------------------------------------------------------------------


shared d_matrix_options

Opts = null
Opts.[File Name] = interimdir + "TRMv6_ExtTransit_Parameter2_Share_TransitMode.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"oneTable"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True


m = CreateSimpleMatrix("TransitMode", numtaz, 8, Opts)

//open the matrix and fill with a default of 0

m = OpenMatrix(Opts.[File Name],)
mc0B = CreateMatrixCurrency(m, "oneTable",,,)
mc0B := 0

//------------------------------------------------------------------------------

//open a file and create a data vector from a column in that file, this vector will be used to fill the above matrix.

TransitMode_Table = OpenTable("Mode", "EXCEL", {excel_file, "pctTransitMode$"}, {{"False", "False"}})
SetView(TransitMode_Table)

// flds = GetFields(TransitMode_Table,"All")
iflds = {"TAZ_TRMv6"}
jflds = {"Share_PK_Trip2", "Share_PK_Trip3", "Share_PK_Trip5", "Share_PK_Trip6", "Share_OP_Trip2", "Share_OP_Trip3", "Share_OP_Trip5", "Share_OP_Trip6" }

//Get values from Share_TransitMode field and import into the 8 vectors

v1 = GetDataVectors(TransitMode_Table+"|", jflds, {{"Sort Order", {{"TAZ_TRMv6", "Ascending"}}}, , , , , "True"})

CloseView(TransitMode_Table)

//Copy the values of Share_TransitMode into rows in the above matrix.

    for i = 1 to v1.length do
	   SetMatrixVector(mc0B, v1[i], {{"Col",i}})
	end


//------------------------------------------------------------------------------
//          Step 0C - Create AttrTAZ matrix.
//------------------------------------------------------------------------------


shared d_matrix_options

Opts = null
Opts.[File Name] = interimdir + "TRMv6_ExtTransit_Parameter3_Share_AttrTAZ.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"PK_Trip2", "PK_Trip3", "PK_Trip5", "PK_Trip6", "OP_Trip2", "OP_Trip3", "OP_Trip5", "OP_Trip6"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True


m = CreateSimpleMatrix("AttrTAZ", numtaz, numtaz, Opts)

//open the matrix and fill with a default of 0

m = OpenMatrix(Opts.[File Name],)
mc0C1 = CreateMatrixCurrency(m, "PK_Trip2",,,)
mc0C1 := 0
mc0C2 = CreateMatrixCurrency(m, "PK_Trip3",,,)
mc0C2 := 0
mc0C3 = CreateMatrixCurrency(m, "PK_Trip5",,,)
mc0C3 := 0
mc0C4 = CreateMatrixCurrency(m, "PK_Trip6",,,)
mc0C4 := 0
mc0C5 = CreateMatrixCurrency(m, "OP_Trip2",,,)
mc0C5 := 0
mc0C6 = CreateMatrixCurrency(m, "OP_Trip3",,,)
mc0C6 := 0
mc0C7 = CreateMatrixCurrency(m, "OP_Trip5",,,)
mc0C7 := 0
mc0C8 = CreateMatrixCurrency(m, "OP_Trip6",,,)
mc0C8 := 0


// -----------------------------------------------------------------------------
//   Create Base Year Peak and Off-Peak Period external transit trip matrices
// -----------------------------------------------------------------------------

//      As noted above, trips 2, 3, 5 and 6 refer to local park and ride, local kiss and ride,
//      express park and ride and express kiss and ride trips, respectively.

   mylist = {"2", "3", "5", "6"}

   for i = 1 to mylist.length do
   str = mylist[i]
   tabname1 = "PK_Trip" + str + "$"
   tabname2 = "PK_Trip_Share" + str + ".mtx"
   tabname3 = "OP_Trip" + str + "$"
   tabname4 = "OP_Trip_Share" + str + ".mtx"

// Create the Peak Period matrices

   tab = OpenTable("PK_Trip_View", "EXCEL", {excel_file, tabname1})
   mtxfile = interimdir + tabname2

   m = CreateMatrixFromView("Matrix", tab+"|", "External_Station", "Internal_TAZ",
       {"Share_Attr_TAZ"}, {{"File Name", mtxfile}})

// Create the Off-Peak Period matrices

   tab = OpenTable("OP_Trip_View", "EXCEL", {excel_file, tabname3})
   mtxfile = interimdir + tabname4

   m = CreateMatrixFromView("Matrix", tab+"|", "External_Station", "Internal_TAZ",
       {"Share_Attr_TAZ"}, {{"File Name", mtxfile}})

   CloseView(tab)

   end


m0C1 = OpenMatrix(interimdir + "PK_Trip_Share2.mtx", "True")
m0C2 = OpenMatrix(interimdir + "PK_Trip_Share3.mtx", "True")
m0C3 = OpenMatrix(interimdir + "PK_Trip_Share5.mtx", "True")
m0C4 = OpenMatrix(interimdir + "PK_Trip_Share6.mtx", "True")
m0C5 = OpenMatrix(interimdir + "OP_Trip_Share2.mtx", "True")
m0C6 = OpenMatrix(interimdir + "OP_Trip_Share3.mtx", "True")
m0C7 = OpenMatrix(interimdir + "OP_Trip_Share5.mtx", "True")
m0C8 = OpenMatrix(interimdir + "OP_Trip_Share6.mtx", "True")
m0C9 = OpenMatrix(interimdir + "TRMv6_ExtTransit_Parameter3_Share_AttrTAZ.mtx", "True")
curr_idx = GetMatrixIndex(m0C1)
// ShowArray(curr_idx)

mc0C1 = CreateMatrixCurrency(m0C1, "Share_Attr_TAZ", "External_Station", "Internal_TAZ",)
targetmc0C1 = CreateMatrixCurrency(m0C9, "PK_Trip2", "Row Index", "Column Index",)
MergeMatrixElements(targetmc0C1, {mc0C1}, null, null, {{"Force Missing", "No"}})

mc0C2 = CreateMatrixCurrency(m0C2, "Share_Attr_TAZ", "External_Station", "Internal_TAZ",)
targetmc0C2 = CreateMatrixCurrency(m0C9, "PK_Trip3", "Row Index", "Column Index",)
MergeMatrixElements(targetmc0C2, {mc0C2}, null, null, {{"Force Missing", "No"}})

mc0C3 = CreateMatrixCurrency(m0C3, "Share_Attr_TAZ", "External_Station", "Internal_TAZ",)
targetmc0C3 = CreateMatrixCurrency(m0C9, "PK_Trip5", "Row Index", "Column Index",)
MergeMatrixElements(targetmc0C3, {mc0C3}, null, null, {{"Force Missing", "No"}})

mc0C4 = CreateMatrixCurrency(m0C4, "Share_Attr_TAZ", "External_Station", "Internal_TAZ",)
targetmc0C4 = CreateMatrixCurrency(m0C9, "PK_Trip6", "Row Index", "Column Index",)
MergeMatrixElements(targetmc0C4, {mc0C4}, null, null, {{"Force Missing", "No"}})

mc0C5 = CreateMatrixCurrency(m0C5, "Share_Attr_TAZ", "External_Station", "Internal_TAZ",)
targetmc0C5 = CreateMatrixCurrency(m0C9, "OP_Trip2", "Row Index", "Column Index",)
MergeMatrixElements(targetmc0C5, {mc0C5}, null, null, {{"Force Missing", "No"}})

mc0C6 = CreateMatrixCurrency(m0C6, "Share_Attr_TAZ", "External_Station", "Internal_TAZ",)
targetmc0C6 = CreateMatrixCurrency(m0C9, "OP_Trip3", "Row Index", "Column Index",)
MergeMatrixElements(targetmc0C6, {mc0C6}, null, null, {{"Force Missing", "No"}})

mc0C7 = CreateMatrixCurrency(m0C7, "Share_Attr_TAZ", "External_Station", "Internal_TAZ",)
targetmc0C7 = CreateMatrixCurrency(m0C9, "OP_Trip5", "Row Index", "Column Index",)
MergeMatrixElements(targetmc0C7, {mc0C7}, null, null, {{"Force Missing", "No"}})

mc0C8 = CreateMatrixCurrency(m0C8, "Share_Attr_TAZ", "External_Station", "Internal_TAZ",)
targetmc0C8 = CreateMatrixCurrency(m0C9, "OP_Trip6", "Row Index", "Column Index",)
MergeMatrixElements(targetmc0C8, {mc0C8}, null, null, {{"Force Missing", "No"}})


//------------------------------------------------------------------------------
//                          Create Matrices
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
//          Step 1 - Create ExtTransit_TotalEIAutoVehicleTrip matrix.
//------------------------------------------------------------------------------

//  Create Total EI Auto Vehicle Trips


m = OpenMatrix(extmatrixin, "True")
curr_idx = GetMatrixIndex(m)
//ShowArray(curr_idx)

mc = CreateMatrixCurrency(m, "Auto EI-IE", "Index", "Index", )
v = GetMatrixVector(mc, {{"Marginal", "Row Sum"}})
//ShowArray({v})

shared d_matrix_options

Opts = null
Opts.[File Name] = interimdir + "ExtTransit_TotalEIAutoVehicleTrip.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"oneTable"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True


m = CreateSimpleMatrix("AutoVehTrips", numtaz, 1, Opts)

m = OpenMatrix(Opts.[File Name],)
mc1 = CreateMatrixCurrency(m, "oneTable",,,)
mc1 := v * 2                            // here we multiply the input values by 2 to translate OD input to PA
// mc1 := v

//------------------------------------------------------------------------------
//          Step 2 - Create ExtTransit_TransitEIAutoVehicleTrip matrix.
//------------------------------------------------------------------------------

MatrixCellbyCell(mc0A, mc1, {{"File Name", interimdir + "ExtTransit_TransitEIAutoVehicleTrip.mtx"},
      {"Label", "Transit Trip Vector Matrix"},
	  {"Type", "Float"},
	  {"Sparse", "No"},
	  {"Column Major", "No"},
	  {"File Based", "Yes"},
	  {"Force Missing", "No"},
	  {"Operator", 1}})

//------------------------------------------------------------------------------
//          Step 3 - Create ExtTransit_TransitPKOPMode matrix.
//------------------------------------------------------------------------------

shared d_matrix_options

Opts = null
Opts.[File Name] = interimdir + "ExtTransit_TransitEIAutoVehicleTrip.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"oneTable"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True

t = OpenMatrix(Opts.[File Name],)
tc1 = CreateMatrixCurrency(t, "Matrix 1",,,)
vec = GetMatrixVector(tc1,{{"Column", 1}})
//ShowArray({vec})

Opts = null
Opts.[File Name] = interimdir + "TRMv6_ExtTransit_Parameter2_Share_TransitMode.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"TransitPKOP"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True

u = OpenMatrix(Opts.[File Name],)
uc3 = CreateMatrixCurrency(u, "oneTable",,,)

Opts = null
Opts.[File Name] = interimdir + "ExtTransit_TransitPKOPMode.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"TransitPKOP"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True

v = CreateSimpleMatrix("TransitPKOP", numtaz, 8, Opts)

v = OpenMatrix(Opts.[File Name],)
vc3 = CreateMatrixCurrency(v, "TransitPKOP",,,)
vc3 := uc3 * vec


//------------------------------------------------------------------------------
//  Step 4 - Create Transit_External_PK.mtx & Transit_External_OP.mtx matrices.
//------------------------------------------------------------------------------


shared d_matrix_options

Opts = null
Opts.[File Name] = interimdir + "ExtTransit_TransitPKOPMode.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"TransitPKOP"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True

PKOP = OpenMatrix(Opts.[File Name],)
PKOPmc1 = CreateMatrixCurrency(PKOP, "TransitPKOP",,,)
vec_PKTrip2 = GetMatrixVector(PKOPmc1,{{"Column", 1}})
vec_PKTrip3 = GetMatrixVector(PKOPmc1,{{"Column", 2}})
vec_PKTrip5 = GetMatrixVector(PKOPmc1,{{"Column", 3}})
vec_PKTrip6 = GetMatrixVector(PKOPmc1,{{"Column", 4}})
vec_OPTrip2 = GetMatrixVector(PKOPmc1,{{"Column", 5}})
vec_OPTrip3 = GetMatrixVector(PKOPmc1,{{"Column", 6}})
vec_OPTrip5 = GetMatrixVector(PKOPmc1,{{"Column", 7}})
vec_OPTrip6 = GetMatrixVector(PKOPmc1,{{"Column", 8}})

Opts = null
Opts.[File Name] = interimdir + "TRMv6_ExtTransit_Parameter3_Share_AttrTAZ.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"PK_Trip2", "PK_Trip3", "PK_Trip5", "PK_Trip6", "OP_Trip2", "OP_Trip3", "OP_Trip5", "OP_Trip6"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True

AttrTAZ = OpenMatrix(Opts.[File Name],)
AttrTAZ_PKTrip2 = CreateMatrixCurrency(AttrTAZ, "PK_Trip2",,,)
AttrTAZ_PKTrip3 = CreateMatrixCurrency(AttrTAZ, "PK_Trip3",,,)
AttrTAZ_PKTrip5 = CreateMatrixCurrency(AttrTAZ, "PK_Trip5",,,)
AttrTAZ_PKTrip6 = CreateMatrixCurrency(AttrTAZ, "PK_Trip6",,,)
AttrTAZ_OPTrip2 = CreateMatrixCurrency(AttrTAZ, "OP_Trip2",,,)
AttrTAZ_OPTrip3 = CreateMatrixCurrency(AttrTAZ, "OP_Trip3",,,)
AttrTAZ_OPTrip5 = CreateMatrixCurrency(AttrTAZ, "OP_Trip5",,,)
AttrTAZ_OPTrip6 = CreateMatrixCurrency(AttrTAZ, "OP_Trip6",,,)


Opts = null
Opts.[File Name] = outdirectory + "Transit_External_PK.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"Trip1", "Trip2", "Trip3", "Trip4", "Trip5", "Trip6", "Trip7", "Trip8", "Trip9"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True

m = CreateSimpleMatrix("Transit_PK", numtaz, numtaz, Opts)

//open the matrix and distribute total transit related Peak auto vehicle trips to Attr TAZ

m = OpenMatrix(Opts.[File Name],)
mc_PKTrip1 = CreateMatrixCurrency(m, "Trip1",,,)
mc_PKTrip1 := 0
mc_PKTrip2 = CreateMatrixCurrency(m, "Trip2",,,)
mc_PKTrip2 := AttrTAZ_PKTrip2 * vec_PKTrip2
mc_PKTrip3 = CreateMatrixCurrency(m, "Trip3",,,)
mc_PKTrip3 := AttrTAZ_PKTrip3 * vec_PKTrip3
mc_PKTrip4 = CreateMatrixCurrency(m, "Trip4",,,)
mc_PKTrip4 := 0
mc_PKTrip5 = CreateMatrixCurrency(m, "Trip5",,,)
mc_PKTrip5 := AttrTAZ_PKTrip5 * vec_PKTrip5
mc_PKTrip6 = CreateMatrixCurrency(m, "Trip6",,,)
mc_PKTrip6 := AttrTAZ_PKTrip6 * vec_PKTrip6
mc_PKTrip7 = CreateMatrixCurrency(m, "Trip7",,,)
mc_PKTrip7 := 0
mc_PKTrip8 = CreateMatrixCurrency(m, "Trip8",,,)
mc_PKTrip8 := 0
mc_PKTrip9 = CreateMatrixCurrency(m, "Trip9",,,)
mc_PKTrip9 := 0


Opts = null
Opts.[File Name] = outdirectory + "Transit_External_OP.mtx"
Opts.Label = "Values"
Opts.Type = "Float"
Opts.Tables = {"Trip1", "Trip2", "Trip3", "Trip4", "Trip5", "Trip6", "Trip7", "Trip8", "Trip9"}
Opts.[Column Major] = "No"
Opts.[File Based] = "Yes"
Opts.Compression = True

m = CreateSimpleMatrix("Transit_OP", numtaz, numtaz, Opts)

//open the matrix and distribute total transit related Off-Peak auto vehicle trips to Attr TAZ

m = OpenMatrix(Opts.[File Name],)
mc_OPTrip1 = CreateMatrixCurrency(m, "Trip1",,,)
mc_OPTrip1 := 0
mc_OPTrip2 = CreateMatrixCurrency(m, "Trip2",,,)
mc_OPTrip2 := AttrTAZ_OPTrip2 * vec_OPTrip2
mc_OPTrip3 = CreateMatrixCurrency(m, "Trip3",,,)
mc_OPTrip3 := AttrTAZ_OPTrip3 * vec_OPTrip3
mc_OPTrip4 = CreateMatrixCurrency(m, "Trip4",,,)
mc_OPTrip4 := 0
mc_OPTrip5 = CreateMatrixCurrency(m, "Trip5",,,)
mc_OPTrip5 := AttrTAZ_OPTrip5 * vec_OPTrip5
mc_OPTrip6 = CreateMatrixCurrency(m, "Trip6",,,)
mc_OPTrip6 := AttrTAZ_OPTrip6 * vec_OPTrip6
mc_OPTrip7 = CreateMatrixCurrency(m, "Trip7",,,)
mc_OPTrip7 := 0
mc_OPTrip8 = CreateMatrixCurrency(m, "Trip8",,,)
mc_OPTrip8 := 0
mc_OPTrip9 = CreateMatrixCurrency(m, "Trip9",,,)
mc_OPTrip9 := 0


tmp = GetViews()
vws = tmp[1]
for i = 1 to vws.length do
     CloseView(vws[i])
     end

     	RunMacro("close everything")

         Return(1)
         quit:
             Return(0)

// ShowMessage("External Transit Trips Complete!")

EndMacro //Macro "ExtTransitTrips" (Args)
