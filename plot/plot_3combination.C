//looping over all histogram files in every subdirs of the DSelector's output file and plot them in a single pdf file with table of content
//Author: Hao Li
//Email: hl2@andrew.cmu.edu 
//Date: 6-5-2017	




#include "TCanvas.h"
#include "TString.h"
#include <iostream>
#include "TFile.h"
#include "TH1I.h"
#include "TH1D.h"
#include "TH2I.h"
#include "TH2D.h"
#include "TKey.h"


using namespace std;

void print_histo(TFile * f1, TFile * f2, TFile * f3, TFile * f4, TString path, Double_t p0, Double_t p1, Double_t p2)
{
	gStyle->SetOptTitle(1);
  	gStyle->SetOptStat("ne");   //show "name" and "entries" only
  	gStyle->SetTitleFontSize(.06);
 	gStyle->SetLabelSize(.06, "XY");


	TFile * h1 = f1;
	TFile * h2 = f2;
	TFile * h3 = f3;
	TFile * h4 = f4;

	//Define a canvas
	gStyle->SetCanvasDefH(600); gStyle->SetCanvasDefW(800);
	TCanvas* canvas = new TCanvas("canvas");
	TString pdfPageOne = path;
	TRegexp repdf1("pdf");
	pdfPageOne(repdf1) = "pdf(";
	canvas->Print(pdfPageOne,"Title: Cover");

	//create an iterator
	TIter nextkey( h1->GetListOfKeys() );
	TKey *key;
	int histocounter=0; //to count number of pages



	//Loop over the keys in the file
	while ( (key = (TKey*)nextkey()))
	{
		//std::cout <<"KEY: "<<key->GetClassName()<<"\t"<<key->GetName()<<";"<<key->GetCycle()<<"\t"<<key->GetTitle()<<std::endl;
		//Read object from first source file
		TObject *obj = key->ReadObj();
		TString keyNameHist = Form("%s",key->GetName());
		cout<< key->GetName() <<endl;

		//Check that the object the key points to is a histogram.
		if( obj->IsA()->InheritsFrom("TH1"))
		{
			//count the number of histograms printed
			histocounter++;
			cout<<histocounter<<endl;

			//cast string for title in pdf's content table. 
			  //NOTE: the title string that contains "vertex" should be avoided.
			TString title = Form("Title: %s",key->GetName());
			if(title.Contains("tex"))
				{
					//use regexp to search and replace the string "tex" with "tx"
					TRegexp re("tex");
					title(re) = "tx";
				}

			//Cast the TObject pointer to a histogram one. Different classes of histos should be treated accordingly, or information will be lost.
			TH1 *histo;
			TH1 *histo_G1;
			TH1 *histo_G2;
			TH1 *histo_G3;
			TH1 *histo_mix;


			if ( strcmp(key->GetClassName(), "TH1D") == 0 ) 
				{
					//retrieve the histograms
					histo = (TH1D*)(obj);
					histo_G1 = (TH1D*) h2->Get(key->GetName());
					histo_G2 = (TH1D*) h3->Get(key->GetName());
					histo_G3 = (TH1D*) h4->Get(key->GetName());
					if( histo==NULL || histo_G1==NULL || histo_G2==NULL || histo_G3==NULL) continue;
					histo_mix = (TH1D*)histo_G1->Clone("histo_G1");

					//change the colors
					histo      ->SetLineColor(kBlue);
					histo_G1   ->SetLineColor(kGreen);
					histo_G2   ->SetLineColor(kMagenta);
					histo_G3   ->SetLineColor(kMagenta+2);
					histo_mix   ->SetLineColor(kRed);
					histo_mix   ->SetMarkerColor(kRed);



						if(histo->Integral()/histo->GetNbinsX()<50){
						histo->Rebin(5);
						histo_G1->Rebin(5);
						histo_G2->Rebin(5);
						histo_G3->Rebin(5);
						histo_mix->Rebin(5);
				}

					//scale
					fscale0=1.0;
					Double_t fscale1 = p0*((histo->Integral())/(histo_G1->Integral()))*fscale0;
					Double_t fscale2 = p1*((histo->Integral())/(histo_G2->Integral()))*fscale0;
					Double_t fscale3 = p2*((histo->Integral())/(histo_G3->Integral()))*fscale0;

					Double_t sum = fscale1+fscale2+fscale3;
					if(title.Contains("BeamEnergy_beam")){
						cout<<fscale1/sum<< ", "<<fscale2/sum<< ", "<<fscale3/sum<< ", "<<endl;
					}
					else{
						//continue;
					}
					
					histo_mix -> Scale(fscale1);
					histo_G1 -> Scale(fscale1);
					histo_G2 -> Scale(fscale2);
					histo_G3 -> Scale(fscale3);

					//mixing the two mechanism
					histo_mix -> Add(histo_G2, 1.0);
					histo_mix -> Add(histo_G3, 1.0);

					if( histo->GetMaximum()>histo_G1->GetMaximum() && histo->GetMaximum()>histo_G2->GetMaximum())
					{
						histo->GetYaxis()->SetRangeUser(0, 1.4*(histo->GetMaximum()));
					}
					else
					{
						if( histo_G1->GetMaximum() > histo_G2->GetMaximum())
						{
							histo->GetYaxis()->SetRangeUser(0, 1.4*(histo_G1->GetMaximum()));
						}
						else
						{
							histo->GetYaxis()->SetRangeUser(0, 1.4*(histo_G2->GetMaximum()));
						}
					}
					
					
					histo->GetXaxis()->SetTitleSize(0.04); 
					histo_G1->SetLineWidth(1);
					histo_G2->SetLineWidth(1);




					if(title.Contains("KinFitCL_precut") && (!title.Contains("Log10"))) histo->SetLineWidth(3); 
					if(title.Contains("BeamEnergy") || (title.Contains("KinFitCL_precut")&& (!title.Contains("Log10"))))
					{
						histo->Draw("HIST");
						histo_G1->Draw("SAME");
						histo_G2->Draw("SAME");
						histo_G3->Draw("SAME");
						histo_mix->Draw("SAME");
					} 
					else
					{
						histo->Draw("E");
						histo_G1->Draw("SAME HIST");
						histo_G2->Draw("SAME HIST");
						histo_G3->Draw("SAME HIST");
						histo_mix->Draw("SAME E");
					}


				}

			if ( strcmp(key->GetClassName(), "TH2D") == 0 ) 
				{
					//continue;
					histo = (TH2D*)(obj); 
					histo_G1 = (TH2D*) h2->Get(key->GetName());
					histo_G2 = (TH2D*) h3->Get(key->GetName());
					histo_G3 = (TH2D*) h4->Get(key->GetName());
					if( histo==NULL || histo_G1==NULL || histo_G2==NULL || histo_G3==NULL) continue;
					histo_mix = (TH2D*)histo_G1->Clone("histo_mix");

					//scale
					Double_t fscale1 = p0*(histo->Integral())/(histo_G1->Integral());
					Double_t fscale2 = p1*(histo->Integral())/(histo_G2->Integral());
					Double_t fscale3 = p2*(histo->Integral())/(histo_G3->Integral());
					histo_G1 -> Scale(fscale1);
					histo_G2 -> Scale(fscale2);
					histo_G3 -> Scale(fscale3);
					
					//mixing the two mechanism
					histo_mix -> Scale(fscale1);
					histo_mix -> Add(histo_G2, 1.0);
					histo_mix -> Add(histo_G3, 1.0);

					canvas->Divide(3,2);

					canvas->cd(1);
					histo->GetXaxis()->SetTitleSize(0.04);
					histo->GetYaxis()->SetTitleSize(0.04); 
					//gPad->SetLogz(); 
					histo->SetOption("COLZ"); 
					histo->Draw();

					canvas->cd(2);
					histo_G1->GetXaxis()->SetTitleSize(0.04);
					histo_G1->GetYaxis()->SetTitleSize(0.04); 
					//gPad->SetLogz(); 
					histo_G1->SetOption("COLZ"); 
					histo_G1->Draw();

					canvas->cd(3);
					histo_G2->GetXaxis()->SetTitleSize(0.04);
					histo_G2->GetYaxis()->SetTitleSize(0.04); 
					//gPad->SetLogz(); 
					histo_G2->SetOption("COLZ"); 
					histo_G2->Draw();

					canvas->cd(5);
					histo_G3->GetXaxis()->SetTitleSize(0.04);
					histo_G3->GetYaxis()->SetTitleSize(0.04); 
					//gPad->SetLogz(); 
					histo_G3->SetOption("COLZ"); 
					histo_G3->Draw();

					canvas->cd(4);
					histo_mix->GetXaxis()->SetTitleSize(0.04);
					histo_mix->GetYaxis()->SetTitleSize(0.04); 
					//gPad->SetLogz(); 
					histo_mix->SetOption("COLZ"); 
					histo_mix->Draw();



					canvas->cd();

					if(title.Contains("vanHovePlot"))
					{
						TLine *line1 = new TLine(-4,0,4,0);
						TLine *line2 = new TLine(-2,-2*sqrt(3),2,2*sqrt(3));
						TLine *line3 = new TLine(-2,2*sqrt(3),2,-2*sqrt(3));
						for(Int_t i =1;i<6;i++)
						{
							canvas->cd(i);
							line1->Draw("SAME");
							line2->Draw("SAME");
							line3->Draw("SAME");
						}
					}

					canvas->cd();
					canvas->Update();
				}
			


			//put extra staff here: grids, lines, lengends...
				//for example, set the zero line for the Missing mass
			

				



			
			//Draw the histogram
			

			//put extra staff here: grids, lines, lengends...
				//for example, set the zero line for the Missing mass
			canvas->Print(path, title);
			canvas->Clear();
			//cout<<title<<"printed"<<endl;

		}
		//for convenience of monitoring plotting activities in the terminal window
		//std::cout<<"----------------------------------"<<std::endl;
		//canvas->Clear();
		
	}

	//Close the .pdf file and delete the canvas
	canvas->Clear();

	

	TString pdfPageEnd = path;
	TRegexp repdf2("pdf");
	pdfPageEnd(repdf2) = "pdf)";
	canvas->Print(pdfPageEnd,"Title: The End");
	delete canvas;
	



}





void recur_copy(TDirectory* source, TDirectory* target)
{

	TDirectory *new_dir = target;
	new_dir->pwd();
    source->cd();
	//create an iterator
	TIter nextkey( source->GetListOfKeys() );
	TKey *key;

	//Loop over the keys in the file
	while ( (key = (TKey*)nextkey()))
	{
		//std::cout <<"KEY: "<<key->GetClassName()<<"\t"<<key->GetName()<<";"<<key->GetCycle()<<"\t"<<key->GetTitle()<<std::endl;
		//Read object from first source file
		TObject *obj = key->ReadObj();
		TString obj_info = Form("TObject (%s): %.5s created.  ",key->GetClassName(),key->GetName());
		//std::cout << obj_info <<std::endl;
		
		//if the object os still a TDirectory, then skip.
		if ( strcmp(key->GetClassName(), "TDirectoryFile") == 0 ) continue;
		

		//Check that the object the key points to is a histogram.
		if ( obj->IsA()->InheritsFrom("TH1") )
		{
			

			//Cast the TObject pointer to a histogram one.
			TH1 *histo;
			if ( strcmp(key->GetClassName(), "TH1D") == 0 ) {histo = (TH1D*)(obj);}
			if ( strcmp(key->GetClassName(), "TH2D") == 0 ) {histo = (TH2D*)(obj);}

			
				//std::cout<< histo_name <<std::endl;
				TString histo_name = Form("%s", key->GetName() );
				histo->SetName(histo_name);
		
			//save the current directory
			TDirectory *save_dir = gDirectory;
			//copy the histogram over to the new file
			new_dir->cd();
			histo->Write();
			save_dir->cd();
		}
		//For convenience of monitoring
		//std::cout<<"----------------------------------"<<std::endl;
		
	}



}

void copy_histo(const char *filename)
{
	//copy all histograms into current directory
	gDirectory->pwd();
	TDirectory *target = gDirectory;

	//open the .root file
	TFile * f1 = new TFile(filename);
	TDirectory *old_dir = gDirectory;
	//check
	if (!f1 || f1->IsZombie()) 
	{
      printf("Cannot copy file: %s\n",filename);
      target->cd();
      return;
   	}
   	target->cd();
   	recur_copy(old_dir, target);
   	target->cd();
}



void plot_3combination(   TString DataPath   = "/raid4/haoli/GlueX_Phase_I/F18lowE_Lo/hist_RunPeriod-2018-08_ver05_antip__B4.root",
		           TString model1_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/F18lowELo/hist_F18lowEv2_ppbarM5b_mc.root",
		           TString model2_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/F18lowELo/hist_F18lowEv2_ppbarM5a_mc.root",
		           TString model3_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/F18lowELo/hist_F18lowEv2_ppbarM6_mc.root",
                   TString plotpath   = "/raid4/haoli/GlueX_Phase_I/plot_result/3combine_hist_F18lowE_vs_data_ratio0_Lo.pdf",
                   Double_t p0  = 0.14, //0.12,
                   Double_t p1  = 0.26, // 0.40,
                   Double_t p2  = 0.60) // 0.48)
/*void plot_3combination(   TString DataPath   = "/raid4/haoli/GlueX_Phase_I/ppbar_diffXsection/hist_RunPeriod-2018-08_ver05_antip__B4.root",
		           TString model1_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/Xsection_thrownNoCut/hist_F18lowEv2_ppbarM5b_mc.root",
		           TString model2_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/Xsection_thrownNoCut/hist_F18lowEv2_ppbarM5a_mc.root",
		           TString model3_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/Xsection_thrownNoCut/hist_F18lowEv2_ppbarM6_mc.root",
                   TString plotpath   = "/raid4/haoli/GlueX_Phase_I/plot_result/3combine_hist_F18lowE_vs_data_ratio0.pdf",
                   Double_t p0  = 0.14, //0.12,
                   Double_t p1  = 0.26, // 0.40,
                   Double_t p2  = 0.60) // 0.48)*/
/*void plot_3combination(   TString DataPath   = "/raid4/haoli/GlueX_Phase_I/ppbar_diffXsection/hist_RunPeriod-2018-08_ver02_antip__B4.root",
		           TString model1_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/Xsection_thrownNoCut/hist_F18v2_ppbarM5b_mc.root",
		           TString model2_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/Xsection_thrownNoCut/hist_F18v2_ppbarM5a_mc.root",
		           TString model3_path     = "/raid4/haoli/MCWrapper/ppbar_2021_01_28_07_30_PM/Xsection_thrownNoCut/hist_F18v2_ppbarM6_mc.root",
                   TString plotpath   = "/raid4/haoli/GlueX_Phase_I/plot_result/3combine_hist_F18_vs_data.pdf",
                   Double_t p0  = 0.14,
                   Double_t p1  = 0.26,
                   Double_t p2  = 0.60)*/
/*void plot_3combination(   TString DataPath   = "/home/haoli/test/Simulation_test/src/dselector/hist_SP17/ver36/ppbar/hist_antip__B4.root",
		           TString model1_path     = "/raid4/haoli/RunPeriod-2017-01/simulation/MCGEN_SP17_01-ver03_ppbar_July21/merged/hist_mech5.root",
		           TString model2_path     = "/raid4/haoli/RunPeriod-2017-01/simulation/MCGEN_SP17_01-ver03_ppbar_July21/merged/hist_mech5_3.root",
		           TString model3_path     = "/raid4/haoli/RunPeriod-2017-01/simulation/MCGEN_SP17_01-ver03_ppbar_July21/merged/hist_mech6.root",
                   TString plotpath   = "/raid4/haoli/RunPeriod-2017-01/simulation/MCGEN_SP17_01-ver03_ppbar_July21/merged/data_3mc_comparison_GJ.pdf",
                   Double_t p0  = 0.26,
                   Double_t p1  = 0.12,
                   Double_t p2  = 0.62)*/
/*void plot_3combination(   TString DataPath   = "/home/haoli/test/Simulation_test/src/dselector/hists_SP18/energy_cut/CoherentPeak/hist.root",
		           TString model1_path     = "/raid4/haoli/2020_MC/ppbar/mech5_tCutoff/tCut0_0/hist_CoherentPeak/hist_antip__B4_0018.root",
		           TString model2_path     = "/raid4/haoli/2020_MC/ppbar/mech5_tCutoff/tCut0_1/hist_CoherentPeak/hist_antip__B4_0018.root",
		           TString model3_path     = "/raid4/haoli/2020_MC/ppbar/mech6_tCutoff5/tCut0/hist_CoherentPeak/hist_antip__B4_0000.root",
                   TString plotpath   = "/home/haoli/test/Simulation_test/src/grid/fit_ppbar/parallel/prod_mech5tCofftCut0_1_mech5tCofftCut0_0_mech6tCoff5tCut0/3Theta_IM_0008/hist_3MC_18_18_0_vs_data_CoherentPeak.pdf",
                   Double_t p0  = 0.26,
                   Double_t p1  = 0.12,
                   Double_t p2  = 0.62)*/
/*void plot_3combination(   TString DataPath   = "/home/haoli/test/Simulation_test/src/dselector/hists_SP18/fitting/standard/hist_antip__B4.root",
		           TString model1_path     = "/raid4/haoli/2020_MC/ppbar/mech5_tCutoff/tCut0_0/hist/hist_antip__B4_0018.root",
		           TString model2_path     = "/raid4/haoli/2020_MC/ppbar/mech5_tCutoff/tCut0_1/hist/hist_antip__B4_0018.root",
		           TString model3_path     = "/raid4/haoli/2020_MC/ppbar/mech6_tCutoff5/tCut0/hist/hist_antip__B4_0000.root",
                   TString plotpath   = "/home/haoli/test/Simulation_test/src/grid/fit_ppbar/parallel/prod_mech5tCofftCut0_1_mech5tCofftCut0_0_mech6tCoff5tCut0/3Theta_IM_0008/hist_3MC_18_18_0_vs_data.pdf",
                   Double_t p0  = 0.26,
                   Double_t p1  = 0.12,
                   Double_t p2  = 0.62)*/
/*void plot_3combination(   TString DataPath   = "/home/haoli/test/Simulation_test/src/dselector/hists_SP18/fitting/standard/hist_antip__B4.root",
		           TString model1_path     = "/raid4/haoli/2020_MC/ppbar/mech5_tCutoff/test0_1/hist/hist_antip__B4_0019.root",
		           TString model2_path     = "/raid4/haoli/2020_MC/ppbar/mech5_tCutoff/test3_4/hist/hist_antip__B4_0034.root",
		           TString model3_path     = "/raid4/haoli/2020_MC/ppbar/mech6_tCutoff5/test0/hist/hist_antip__B4_0063.root",
                   TString plotpath   = "/home/haoli/test/Simulation_test/src/grid/fit_ppbar/parallel/products_mech5tCofftest0_1_mech5tCofftest3_4_mech6tCoff5test0_normalized10percent/3Theta_IM_0019/hist_3MC_19_34_63_vs_data.pdf",
                   Double_t p0  = 0.26,
                   Double_t p1  = 0.14,
                   Double_t p2  = 0.60)*/
/*void plot_3combination(   TString DataPath   = "/home/haoli/test/Simulation_test/src/dselector/hists_SP18/geometryCutat1/hist_antip__B4_CL5_Acc.root",
		           TString model1_path     = "/raid4/haoli/2020_MC/ppbar/mech5_tCutoff2/test1/hist/hist_antip__B4_0095.root",
		           TString model2_path     = "/raid4/haoli/2020_MC/ppbar/mech5_tCutoff/test3/hist/hist_antip__B4_0009.root",
		           TString model3_path     = "/raid4/haoli/2020_MC/ppbar/mech6_tCutoff4/test2/hist/hist_antip__B4_0055.root",
                   TString plotpath   = "/home/haoli/test/Simulation_test/src/plot/product_ppbar/ppbar_3combinations_fixedmech5test3tCutat05_0_mech5test3tCutat05_mech6tCutoff4test2_vs_data3.pdf",
                   Double_t p0  = 0.15,
                   Double_t p1  = 0.39,
                   Double_t p2  = 0.46)*/
{
	

	//call the copy_histo() function recursively (i.e. loop over every histogram in all the subdirectories of the .root file) to copy every histogram in to a new .root file
	TFile* h1 = new TFile("/home/haoli/Lambda/plots/hist_fulldata_temp_plots1.root","RECREATE");
	gDirectory->pwd();
	std::cout<<"---------------------------------------------------------------------------------------"<<std::endl;
	copy_histo(DataPath);
	
	//call the copy_histo() function recursively (i.e. loop over every histogram in all the subdirectories of the .root file) to copy every histogram in to a new .root file
	TFile* h2 = new TFile("/home/haoli/Lambda/plots/hist_signal_temp_plots1.root","RECREATE");
	gDirectory->pwd();
	std::cout<<"---------------------------------------------------------------------------------------"<<std::endl;
	copy_histo(model1_path);
	
	//call the copy_histo() function recursively (i.e. loop over every histogram in all the subdirectories of the .root file) to copy every histogram in to a new .root file
	TFile* h3 = new TFile("/home/haoli/Lambda/plots/hist_left_temp_plots1.root","RECREATE");
	gDirectory->pwd();
	std::cout<<"---------------------------------------------------------------------------------------"<<std::endl;
	copy_histo(model2_path);

	//call the copy_histo() function recursively (i.e. loop over every histogram in all the subdirectories of the .root file) to copy every histogram in to a new .root file
	TFile* h4 = new TFile("/home/haoli/Lambda/plots/hist_left_temp_plots1.root","RECREATE");
	gDirectory->pwd();
	std::cout<<"---------------------------------------------------------------------------------------"<<std::endl;
	copy_histo(model3_path);

	

	//avoid crash
	gROOT->Reset();

	//loop over the new .root file to plot everything in a .pdf file
	print_histo(h1, h2, h3, h4, plotpath, p0, p1, p2);
	


}


















