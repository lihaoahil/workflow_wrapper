Int_t Get_PolarizationAngle(Int_t loc_runNumber){
	//RCDB environment must be setup!!

	//Pipe the current constant into this function
	ostringstream locCommandStream;
	locCommandStream << "rcnd " << loc_runNumber << " polarization_angle";
	FILE* locInputFile = gSystem->OpenPipe(locCommandStream.str().c_str(), "r");
	if(locInputFile == NULL)
		return -999;

	//get the first line
	char buff[1024];
	if(fgets(buff, sizeof(buff), locInputFile) == NULL)
		return 0;
	istringstream locStringStream(buff);

	//Close the pipe
	gSystem->ClosePipe(locInputFile);

	//extract it
	string locPolarizationAngleString;
	if(!(locStringStream >> locPolarizationAngleString))
		return -999;

	// convert string to integer
	int locPolarizationAngle = atoi(locPolarizationAngleString.c_str());
	return locPolarizationAngle;

}


void plot_efficiency(TString reaction){
	//Set this globally
	gStyle->SetOptStat(0);
	TString loc_reaction = reaction;
	
	// LIST
	TString RunPeriods [] = {"S17v3", "S18v2", "F18v2", "F18lowEv2"};
	TString Runs_sp17 [] = {"030274", "030276", "030277", "030279", "030280", "030281", "030282", "030283", "030284", "030285", "030286", "030298", "030299", "030300", "030320", "030321", "030322", "030323", "030324", "030326", "030327", "030329", "030330", "030331", "030332", "030343", "030344", "030345", "030346", "030347", "030348", "030349", "030350", "030351", "030352", "030355", "030361", "030380", "030381", "030383", "030384", "030385", "030386", "030387", "030388", "030389", "030390", "030401", "030402", "030403", "030404", "030405", "030406", "030407", "030408", "030409", "030410", "030411", "030420", "030421", "030422", "030424", "030428", "030429", "030431", "030432", "030433", "030434", "030436", "030437", "030441", "030442", "030446", "030447", "030448", "030449", "030450", "030451", "030452", "030453", "030454", "030455", "030459", "030460", "030461", "030462", "030463", "030464", "030465", "030466", "030467", "030468", "030469", "030470", "030471", "030473", "030474", "030477", "030480", "030481", "030482", "030484", "030485", "030486", "030487", "030488", "030489", "030490", "030493", "030494", "030495", "030496", "030497", "030499", "030567", "030568", "030570", "030571", "030575", "030577", "030578", "030579", "030580", "030581", "030582", "030586", "030587", "030589", "030590", "030591", "030592", "030593", "030595", "030596", "030597", "030598", "030600", "030602", "030607", "030608", "030610", "030611", "030612", "030614", "030616", "030618", "030620", "030621", "030622", "030623", "030624", "030625", "030626", "030627", "030629", "030630", "030632", "030633", "030634", "030635", "030636", "030637", "030638", "030639", "030641", "030642", "030643", "030648", "030649", "030650", "030651", "030652", "030653", "030654", "030655", "030656", "030657", "030658", "030659", "030660", "030666", "030667", "030668", "030672", "030673", "030674", "030675", "030676", "030677", "030678", "030679", "030680", "030682", "030684", "030686", "030687", "030688", "030690", "030693", "030694", "030695", "030696", "030697", "030698", "030699", "030701", "030730", "030731", "030732", "030733", "030734", "030735", "030736", "030737", "030738", "030739", "030740", "030741", "030742", "030743", "030744", "030745", "030749", "030754", "030769", "030770", "030778", "030779", "030780", "030783", "030784", "030785", "030787", "030788", "030796", "030797", "030800", "030801", "030802", "030803", "030804", "030805", "030807", "030808", "030809", "030810", "030811", "030812", "030813", "030815", "030816", "030818", "030821", "030822", "030823", "030824", "030826", "030827", "030829", "030830", "030833", "030834", "030835", "030836", "030838", "030839", "030840", "030841", "030842", "030843", "030844", "030847", "030848", "030855", "030856", "030857", "030858", "030859", "030888", "030889", "030890", "030891", "030893", "030895", "030896", "030898", "030899", "030900", "030902", "030903", "030920", "030923", "030924", "030926", "030927", "030928", "030929", "030930", "030947", "030951", "030952", "030953", "030954", "030955", "030956", "030957", "030958", "030959", "030961", "030962", "030963", "030964", "030965", "030966", "030980", "030981", "030982", "030992", "030993", "030994", "030995", "030996", "030998", "030999", "031000", "031001", "031002", "031003", "031004", "031005", "031018", "031023", "031029", "031031", "031032", "031034", "031036", "031046", "031049", "031050", "031051", "031052", "031053", "031054", "031055", "031056", "031057"};
	TString Runs_sp18 [] = {"040856", "040857", "040858", "040859", "040860", "040861", "040865", "040869", "040881", "040883", "040884", "040893", "040894", "040895", "040896", "040902", "040907", "040911", "040915", "040931", "040933", "040934", "040941", "040943", "040945", "040946", "040947", "040948", "040949", "040950", "040951", "040967", "040968", "040975", "040978", "040981", "040982", "040984", "040985", "040986", "040987", "040988", "040992", "040993", "040994", "040995", "040996", "040997", "040999", "041000", "041002", "041003", "041005", "041006", "041007", "041008", "041041", "041044", "041046", "041048", "041069", "041070", "041073", "041074", "041075", "041077", "041078", "041079", "041080", "041084", "041085", "041088", "041089", "041097", "041099", "041100", "041102", "041106", "041107", "041108", "041110", "041111", "041112", "041113", "041114", "041116", "041117", "041118", "041119", "041120", "041122", "041124", "041128", "041130", "041131", "041132", "041133", "041134", "041135", "041136", "041137", "041138", "041139", "041141", "041142", "041143", "041144", "041145", "041147", "041148", "041149", "041150", "041151", "041152", "041172", "041173", "041174", "041175", "041178", "041180", "041186", "041187", "041197", "041202", "041203", "041204", "041205", "041206", "041207", "041208", "041209", "041210", "041211", "041212", "041213", "041214", "041215", "041216", "041217", "041218", "041220", "041221", "041222", "041225", "041245", "041246", "041247", "041249", "041250", "041251", "041252", "041253", "041254", "041255", "041256", "041257", "041258", "041259", "041260", "041261", "041264", "041265", "041267", "041268", "041273", "041274", "041275", "041276", "041280", "041282", "041287", "041288", "041290", "041291", "041292", "041293", "041294", "041295", "041373", "041374", "041376", "041378", "041379", "041380", "041383", "041384", "041385", "041386", "041388", "041425", "041426", "041427", "041428", "041429", "041430", "041432", "041433", "041434", "041435", "041440", "041441", "041442", "041444", "041445", "041447", "041450", "041451", "041452", "041453", "041454", "041455", "041456", "041457", "041458", "041461", "041464", "041465", "041466", "041467", "041469", "041470", "041471", "041472", "041473", "041474", "041475", "041477", "041479", "041482", "041483", "041484", "041485", "041486", "041487", "041488", "041489", "041490", "041491", "041492", "041493", "041494", "041495", "041496", "041499", "041508", "041509", "041510", "041511", "041528", "041530", "041531", "041541", "041542", "041543", "041544", "041545", "041546", "041548", "041564", "041565", "041566", "041570", "041571", "041572", "041573", "041574", "041575", "041576", "041577", "041578", "041579", "041580", "041581", "041582", "041583", "041584", "041585", "041586", "041590", "041592", "041598", "041605", "041606", "041607", "041609", "041624", "041627", "041628", "041629", "041630", "041632", "041860", "041862", "041863", "041864", "041871", "041872", "041873", "041874", "041876", "041877", "041878", "041879", "041880", "041884", "041885", "041886", "041887", "041888", "041889", "041896", "041897", "041898", "041917", "041918", "041919", "041920", "041936", "041938", "041941", "041942", "041956", "041976", "041977", "041978", "041979", "041980", "041985", "041989", "042006", "042007", "042009", "042010", "042011", "042012", "042013", "042014", "042015", "042016", "042017", "042027", "042028", "042029", "042030", "042031", "042032", "042033", "042034", "042037", "042038", "042039", "042040", "042041", "042043", "042044", "042045", "042055", "042056", "042057", "042058", "042059", "042075", "042076", "042077", "042080", "042101", "042102", "042103", "042104", "042117", "042118", "042119", "042120", "042121", "042122", "042123", "042124", "042125", "042132", "042133", "042134", "042135", "042137", "042138", "042144", "042145", "042146", "042147", "042149", "042150", "042151", "042153", "042154", "042155", "042156", "042157", "042158", "042173", "042182", "042183", "042184", "042185", "042186", "042187", "042188", "042193", "042221", "042234", "042236", "042237", "042239", "042241", "042242", "042243", "042245", "042246", "042247", "042248", "042249", "042250", "042251", "042252", "042253", "042254", "042255", "042256", "042257", "042258", "042259", "042260", "042261", "042262", "042263", "042264", "042265", "042266", "042267", "042268", "042269", "042270", "042271", "042272", "042273", "042274", "042276", "042277", "042278", "042279", "042280", "042281", "042282", "042320", "042321", "042322", "042323", "042346", "042347", "042348", "042349", "042350", "042351", "042352", "042374", "042381", "042382", "042383", "042384", "042385", "042386", "042387", "042388", "042389", "042390", "042395", "042397", "042398", "042399", "042400", "042401", "042402", "042403", "042404", "042420", "042421", "042422", "042423", "042424", "042425", "042426", "042427", "042428", "042429", "042432", "042433", "042434", "042436", "042437", "042438", "042439", "042442", "042443", "042444", "042445", "042446", "042447", "042448", "042457", "042459", "042460", "042480", "042481", "042482", "042483", "042484", "042485", "042486", "042495", "042496", "042500", "042501", "042502", "042503", "042504", "042505", "042506", "042507", "042512", "042513", "042514", "042545", "042546", "042547", "042550", "042551", "042552", "042553", "042554", "042555", "042556", "042557", "042558", "042559"};
	TString Runs_fl18 [] = {"050685", "050697", "050698", "050699", "050700", "050701", "050702", "050703", "050704", "050705", "050706", "050707", "050709", "050710", "050712", "050715", "050716", "050726", "050727", "050728", "050729", "050733", "050737", "050738", "050739", "050740", "050741", "050742", "050743", "050744", "050745", "050746", "050750", "050751", "050752", "050753", "050754", "050755", "050756", "050757", "050758", "050759", "050768", "050770", "050771", "050772", "050773", "050774", "050775", "050783", "050784", "050785", "050786", "050787", "050797", "050798", "050799", "050801", "050802", "050804", "050806", "050807", "050808", "050809", "050810", "050811", "050812", "050813", "050814", "050815", "050816", "050817", "050835", "050836", "050838", "050839", "050840", "050841", "050847", "050856", "050857", "050858", "050859", "050864", "050904", "050905", "050907", "050908", "050909", "050911", "050914", "050915", "050917", "050919", "050927", "050928", "050929", "050930", "050931", "050932", "050933", "050934", "050935", "050936", "050937", "050939", "050940", "050941", "050942", "050943", "050944", "050945", "050946", "050947", "050948", "050950", "050951", "050952", "050955", "050956", "050958", "050959", "050961", "050979", "050981", "050982", "050983", "050984", "050985", "050986", "050987", "051017", "051018", "051019", "051020", "051027", "051028", "051029", "051030", "051031", "051032", "051033", "051034", "051035", "051037", "051038", "051039", "051040", "051041", "051045", "051046", "051047", "051048", "051049", "051050", "051051", "051052", "051053", "051054", "051055", "051056", "051057", "051058", "051059", "051060", "051061", "051062", "051063", "051064", "051065", "051066", "051067", "051068", "051069", "051070", "051071", "051072", "051073", "051074", "051075", "051076", "051077", "051078", "051079", "051095", "051096", "051097", "051098", "051099", "051100", "051101", "051114", "051115", "051116", "051117", "051118", "051119", "051140", "051142", "051143", "051145", "051150", "051151", "051152", "051153", "051154", "051155", "051156", "051157", "051158", "051159", "051160", "051161", "051162", "051163", "051164", "051165", "051166", "051167", "051169", "051170", "051171", "051172", "051173", "051174", "051175", "051176", "051177", "051178", "051179", "051192", "051193", "051194", "051195", "051196", "051198", "051199", "051200", "051201", "051202", "051203", "051204", "051205", "051209", "051210", "051212", "051213", "051214", "051224", "051225", "051226", "051227", "051228", "051233", "051234", "051235", "051236", "051237", "051248", "051249", "051250", "051251", "051252", "051253", "051254", "051256", "051260", "051261", "051262", "051263", "051264", "051265", "051266", "051267", "051268", "051269", "051270", "051271", "051272", "051273", "051282", "051283", "051284", "051285", "051286", "051287", "051288", "051289", "051290", "051291", "051292", "051293", "051295", "051296", "051302", "051303", "051304", "051305", "051306", "051309", "051310", "051311", "051312", "051313", "051314", "051315", "051316", "051317", "051318", "051319", "051321", "051322", "051323", "051324", "051325", "051326", "051327", "051328", "051329", "051331", "051332", "051333", "051335", "051336", "051337", "051362", "051363", "051364", "051365", "051366", "051367", "051368", "051369", "051497", "051498", "051499", "051500", "051502", "051503", "051504", "051505", "051506", "051507", "051508", "051510", "051511", "051512", "051513", "051514", "051515", "051516", "051517", "051518", "051519", "051520", "051521", "051522", "051523", "051524", "051537", "051539", "051540", "051542", "051543", "051544", "051545", "051558", "051559", "051560", "051561", "051562", "051563", "051564", "051565", "051566", "051567", "051568", "051569", "051570", "051571", "051572", "051573", "051574", "051575", "051576", "051577", "051578", "051579", "051580", "051581", "051582", "051583", "051585", "051586", "051587", "051589", "051590", "051591", "051592", "051593", "051594", "051595", "051596", "051597", "051598", "051599", "051600", "051601", "051602", "051603", "051618", "051619", "051628", "051629", "051630", "051631", "051632", "051633", "051634", "051635", "051636", "051637", "051638", "051683", "051685", "051686", "051687", "051722", "051723", "051724", "051725", "051726", "051727", "051728", "051729", "051730", "051731", "051732", "051733", "051734", "051735", "051748", "051749", "051762", "051763", "051764", "051765", "051766", "051767", "051768"};
	TString Runs_lowE [] = {"051384", "051386", "051387", "051388", "051389", "051390", "051391", "051392", "051393", "051394", "051395", "051396", "051397", "051398", "051399", "051400", "051401", "051402", "051408", "051409", "051410", "051426", "051427", "051431", "051432", "051433", "051434", "051435", "051436", "051437", "051438", "051440", "051441", "051442", "051443", "051444", "051445", "051446", "051447", "051448", "051449", "051450", "051451", "051453", "051454", "051455", "051456", "051457"};


	TString ObservableName = "BeamEnergy_100binsBeam";
	Color_t color [] = {kWhite, kRed, kGreen, kBlue, kMagenta};

		//for ppbar (need if branches for other reactions later!)
		TString mechName [] = {"M6", "M5a", "M5b"};
	    Double_t combineRatio [] = {0.51, 0.23, 0.26};

	// PATH
	TString sim_path  = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/run_by_run";
	TString data_path = "/raid4/haoli/GlueX_Phase_I/run_by_run";
	TString flux_path = "/home/haoli/ifarm/run_by_run_flux";

	//bin: E_min and bin: E_max
	Int_t bin_Emin = 44;
	Int_t bin_Emax = 95;

	//set up the canvas
	Int_t loc_width = 2800;
	Int_t loc_height = 1000;



	// Loop over Run Periods
	for(int p = 0; p<4; p++){

		//set up the canvas
		TCanvas *ny = new TCanvas("ny", "ny", loc_width, loc_height);
		TCanvas *ny1 = new TCanvas("ny1", "ny1", loc_width, loc_height);
		TCanvas *ny2 = new TCanvas("ny2", "ny2", loc_width, loc_height);

		//if(p!=3) continue;
		//set up run numbers and copy list
		Int_t num_runs;
		TString RunList [600];
		Double_t RunNumber [600];
		Double_t RunNumber_err [600];
		if(p==0){
			num_runs = (int)(sizeof(Runs_sp17)/sizeof(Runs_sp17[0]));
			for(int i=0;i<num_runs;i++) RunList[i]=Runs_sp17[i];
		}
		else if(p==1){
			num_runs = (int)(sizeof(Runs_sp18)/sizeof(Runs_sp18[0]));
			for(int i=0;i<num_runs;i++) RunList[i]=Runs_sp18[i];
		}
		else if(p==2){
			num_runs = (int)(sizeof(Runs_fl18)/sizeof(Runs_fl18[0]));
			for(int i=0;i<num_runs;i++) RunList[i]=Runs_fl18[i];
		}
		else if(p==3){
			num_runs = (int)(sizeof(Runs_lowE)/sizeof(Runs_lowE[0]));
			for(int i=0;i<num_runs;i++) RunList[i]=Runs_lowE[i];
		}

		Double_t arr_Flux [600];
		Double_t arr_Raw [600];
		Double_t arr_FluxCorrected [600];  // data normalized by tagged flux
		Double_t arr_MC [600];
		Double_t arr_Thrown [600];
		Double_t arr_Efficiency [600];     // observed mc divided by thrown mc
		Double_t arr_Xsection [600];

		Double_t arr_Flux_err [600];
		Double_t arr_Raw_err [600];
		Double_t arr_FluxCorrected_err [600];  // data normalized by tagged flux
		Double_t arr_MC_err [600];
		Double_t arr_Thrown_err [600];
		Double_t arr_Efficiency_err [600];     // observed mc divided by thrown mc
		Double_t arr_Xsection_err [600];

		//initialize
		for(int i = 0; i<600; i++){
			arr_Flux[i] = 0;
			arr_Raw[i] = 0;
			arr_FluxCorrected[i] = 0;  // data normalized by tagged flux
			arr_MC[i] = 0;
			arr_Thrown[i] = 0;
			arr_Efficiency[i] = 0;     // observed mc divided by thrown mc
			arr_Xsection[i] = 0;

			arr_Flux_err[i] = 0;
			arr_Raw_err[i] = 0;
			arr_FluxCorrected_err[i] = 0;  // data normalized by tagged flux
			arr_MC_err[i] = 0;
			arr_Thrown_err[i] = 0;
			arr_Efficiency_err[i] = 0;     // observed mc divided by thrown mc
			arr_Xsection_err[i] = 0;

			RunNumber[i] = 0;
			RunNumber_err[i] = 2;
		}

		//loop over the run number
		for(int i = 0; i< num_runs; i++){  // contains magic string "000"!
			//turn string into number
			RunNumber[i]=atoi(RunList[i]); 
			TString RunString = RunList[i]; 
			RunString.Remove(0,1);
			RunNumber_err[i] = 0;

			if(RunNumber[i] == 31049) continue;

			//data and flux
			TString flux_name = flux_path + "/flux_" + RunString + "_" + RunString + ".root"; 
			TString data_name = data_path + "/hist_" + RunPeriods[p] + "_" + reaction  + "_" + RunList[i] + "_data.root";
			if(gSystem->AccessPathName(flux_name) || gSystem->AccessPathName(data_name)){
				continue;
			}	

			TFile * loc_fluxFile = TFile::Open(flux_name);
			TFile * loc_dataFile = TFile::Open(data_name); 
			TH1D * hist_flux = (TH1D*)loc_fluxFile->Get("tagged_flux");
			TH1D * hist_data = (TH1D*)loc_dataFile->Get(ObservableName);

			if(p==3){
				arr_Flux[i] = hist_flux->Integral(18,39);
			}
			else{
				arr_Flux[i] = hist_flux->Integral(bin_Emin, bin_Emax); //(44,95);
			}
			

			if(arr_Flux[i]==0){
				arr_FluxCorrected[i] = 0;
			}
			else{ 
				if(p==3){
					arr_Raw[i] = hist_data->Integral(18,39);
					arr_FluxCorrected[i] = arr_Raw[i]/arr_Flux[i];
				}
				else{
					arr_Raw[i] = hist_data->Integral(bin_Emin, bin_Emax);
					arr_FluxCorrected[i] = arr_Raw[i]/arr_Flux[i];
				}
			}
			delete loc_fluxFile;
			delete loc_dataFile;


			// loop over mech
			Int_t num_mechs = (sizeof(mechName)/sizeof(mechName[0]));
			Double_t loc_errorMC_square = 0;
			Bool_t Sim_flag = true;

			for(int m = 0; m < num_mechs; m++){ 
				TString mc_Name = sim_path + "/hist_" + RunPeriods[p] + "_" + reaction + mechName[m] + "_mc_" + RunList[i] + "_000_mc.root";
				TString gen_Name = sim_path + "/hist_" + RunPeriods[p] + "_" +  reaction + mechName[m] + "_GEN_" + RunList[i] + "_000_thrown.root";
				if(gSystem->AccessPathName(mc_Name) || gSystem->AccessPathName(gen_Name)){
					cout<< RunList[i]<< ": no MC file!"<<endl;
					Sim_flag=false;
					continue;
				}
				TFile * loc_mcFile = TFile::Open(mc_Name);
				TFile * loc_genFile = TFile::Open(gen_Name); 

				TH1D * hist_mc = (TH1D*)loc_mcFile->Get(ObservableName);
				TH1D * hist_thrown = (TH1D*)loc_genFile->Get(ObservableName);

				Double_t N_mc, N_thrown;
				if(p==3){
					N_mc = hist_mc->Integral(18, 39);
					N_thrown = hist_thrown->Integral(18, 39);
				}
				else{
					N_mc = hist_mc->Integral(bin_Emin, bin_Emax);
					N_thrown = hist_thrown->Integral(bin_Emin, bin_Emax);
				}

				delete loc_mcFile;
				delete loc_genFile;

				//store to the arrays
				arr_MC[i]     += combineRatio[m]*N_mc;
				arr_Thrown[i] += combineRatio[m]*N_thrown;
				loc_errorMC_square += combineRatio[m]*combineRatio[m]*(N_mc); //combineRatio[m]*combineRatio[m]*(1.0/N_mc + 1.0/N_thrown); 

			}//end of mech loop

			if(Sim_flag){
				arr_Efficiency[i] = arr_MC[i]/arr_Thrown[i];
			}
			else{
				arr_Efficiency[i] = 0;
			}
			
			if(arr_Efficiency[i]==0){
					arr_Xsection[i] = 0;
			} 
			else{
					if(p==0) {
						arr_FluxCorrected[i] = arr_FluxCorrected[i]*(1.0/1.27e-9);
						arr_Xsection[i] = arr_FluxCorrected[i]*(1.0/arr_Efficiency[i]); // value for 2017 H2 target thickness
					}
					else{
						arr_FluxCorrected[i] = arr_FluxCorrected[i]*(1.0/1.26e-9);
						arr_Xsection[i] = arr_FluxCorrected[i]*(1.0/arr_Efficiency[i]); // value for 2018 H2 target thickness
					}				
			}

			//error propagation
			arr_Flux_err[i] = sqrt(arr_Flux[i]);
			arr_Raw_err[i] = sqrt(arr_Raw[i]);
			arr_MC_err[i] = sqrt(arr_MC[i]);
			arr_Thrown_err[i] = sqrt(arr_Thrown[i]);

			Double_t err1square, err2square;
			if(arr_Flux[i]==0||arr_Raw[i]==0){
				err1square = 0;
				arr_FluxCorrected_err[i] = 0;
			}
			else{ 
				err1square = 1.0/arr_Flux[i] + 1.0/arr_Raw[i];
				arr_FluxCorrected_err[i] = arr_FluxCorrected[i]*sqrt(err1square);  
			}

			if(arr_MC[i]==0||arr_Thrown[i]==0){
				err2square = 0;
				arr_Efficiency_err[i] = 0; 
			}
			else{
				err2square = loc_errorMC_square/(arr_MC[i]*arr_MC[i]);
				arr_Efficiency_err[i] = arr_Efficiency[i]*sqrt(err2square); 
			}
			
			if(arr_Flux[i]==0||arr_Raw[i]==0||arr_MC[i]==0||arr_Thrown[i]==0){
				arr_Xsection_err[i] = 0;
			}
			else{
				arr_Xsection_err[i] = arr_Xsection[i]*sqrt(err1square+err2square);
			}

			//safeguard
			if(arr_Efficiency_err[i]>arr_Efficiency[i]) arr_Efficiency_err[i]=arr_Efficiency[i];
			//if(arr_Xsection_err[i]>arr_Xsection[i]) arr_Xsection_err[i]=arr_Xsection[i];
			

			
			// calculate weighted average of eff
			cout << RunList[i]<<": Raw Yield=" << arr_Raw[i]<<"+/-"<<arr_Raw_err[i] << " flux=" << arr_Flux[i]<<"+/-"<<arr_Flux_err[i]  << ", fluxNormalizedYield=" << arr_FluxCorrected[i]<<"+/-"<<arr_FluxCorrected_err[i] << ", Eff=" << arr_Efficiency[i]<<"+/-"<<arr_Efficiency_err[i] << ", Xsection=" << arr_Xsection[i]<<"+/-"<<arr_Xsection_err[i] << endl;


		}//end of run loop


		
		// plot efficiency
		TGraph *gr = new TGraphErrors(600, RunNumber, arr_Efficiency, RunNumber_err, arr_Efficiency_err);
		ny->cd();
    	gPad->SetGrid();
		gr->SetMarkerStyle(1);
		gr->SetMarkerSize(0.1);
		cout << RunNumber[0]<<" "<<RunNumber[num_runs-1]<< endl;
		gr->SetTitle(RunPeriods[p]);
		gr->GetYaxis()->SetTitle("efficiency");
		gr->GetXaxis()->SetRangeUser(RunNumber[0],RunNumber[num_runs-1]);
		gr->Draw("AP");

		// plot flux normalized yield
		TGraph *gr1 = new TGraphErrors(600, RunNumber, arr_FluxCorrected, RunNumber_err, arr_FluxCorrected_err);
		ny1->cd();
    	gPad->SetGrid();
		gr1->SetMarkerStyle(1);
		gr1->SetMarkerSize(0.1);
		gr1->SetTitle(RunPeriods[p]);
		gr1->GetYaxis()->SetTitle("normalized yield (nb)"); 
		gr1->GetXaxis()->SetRangeUser(RunNumber[0],RunNumber[num_runs-1]);
		gr1->Draw("AP");

		// plot
		TGraph *gr2 = new TGraphErrors(600, RunNumber, arr_Xsection, RunNumber_err, arr_Xsection_err);
		ny2->cd();
    	gPad->SetGrid();
		gr2->SetMarkerStyle(1);
		gr2->SetMarkerSize(0.1);
		gr2->SetTitle(RunPeriods[p]);
		gr2->GetYaxis()->SetTitle("#sigma (nb)"); 
		gr2->GetXaxis()->SetRangeUser(RunNumber[0],RunNumber[num_runs-1]);
		gr2->Draw("AP");

		TMarker *m, *m1, *m2;
	    Double_t x, y, x1, y1, x2, y2;
		for (int i=0; i<num_runs; i++) {
			gr->GetPoint(i,x,y);
			gr1->GetPoint(i,x1,y1);
			gr2->GetPoint(i,x2,y2);
			//get polarization angle
			Int_t loc_runNumber = atoi(RunList[i]);
			Int_t polar_angle = -1;//Get_PolarizationAngle(loc_runNumber);
			cout << loc_runNumber << ", polar angle=" << polar_angle << endl;
			m = new TMarker(x,y,20);
			m1 = new TMarker(x1,y1,20);
			m2 = new TMarker(x2,y2,20);
			m->SetMarkerSize(0.8);
			m1->SetMarkerSize(0.8);
			m2->SetMarkerSize(0.8);

			if(polar_angle ==  -1){
				m->SetMarkerColor(kBlack); m->SetMarkerStyle(4);  
				m1->SetMarkerColor(kBlack); m1->SetMarkerStyle(4); 
				m2->SetMarkerColor(kBlack); m2->SetMarkerStyle(4); 
				m->SetMarkerSize(1.2);
				m1->SetMarkerSize(1.2);
				m2->SetMarkerSize(1.2);
			}
			else if(polar_angle == 0){
				m->SetMarkerColor(kRed); 
				m1->SetMarkerColor(kRed); 
				m2->SetMarkerColor(kRed); 
				m->SetMarkerStyle(20); 
				m1->SetMarkerStyle(20); 
				m2->SetMarkerStyle(20); 
			}
			else if(polar_angle ==  45){
				m->SetMarkerColor(kGreen);
				m1->SetMarkerColor(kGreen);
				m2->SetMarkerColor(kGreen);	
				m->SetMarkerStyle(21); 
				m1->SetMarkerStyle(21); 
				m2->SetMarkerStyle(21); 			
			}
			else if(polar_angle ==  90){
				m->SetMarkerColor(kBlue);
				m1->SetMarkerColor(kBlue);
				m2->SetMarkerColor(kBlue);
				m->SetMarkerStyle(22); 
				m1->SetMarkerStyle(22); 
				m2->SetMarkerStyle(22);	
			}
			else if(polar_angle == 135){
				m->SetMarkerColor(kMagenta);
				m1->SetMarkerColor(kMagenta);
				m2->SetMarkerColor(kMagenta);	
				m->SetMarkerStyle(23); 
				m1->SetMarkerStyle(23); 
				m2->SetMarkerStyle(23);	
			}
			ny->cd(); m->Draw("AP SAME");
			ny1->cd(); m1->Draw("AP SAME");
			ny2->cd(); m2->Draw("AP SAME");
		}
		
		ny->SaveAs("err2_perRun_"+RunPeriods[p]+"efficiency.png");
		ny1->SaveAs("err2_perRun_"+RunPeriods[p]+"normalizedYield.png");
		ny2->SaveAs("err2_perRun_"+RunPeriods[p]+"sigma.png");

	}//done with loop over Run Periods
	cout<<"done with all the plotting."<<endl;

}




void run_by_run_efficiency(){

	// Reaction
	TString reaction = "ppbar";

	plot_efficiency(reaction);
}