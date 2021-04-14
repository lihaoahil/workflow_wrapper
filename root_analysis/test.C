void test(){

	Int_t a = 10;
	Int_t b = 10;
	Double_t x[10][20];

	for(int i=0;i<a;i++){
		for(int j=0;j<b;j++){
			x[i][j] = i*j;
			cout<< x[i][j] << " ";
		}
		cout<<endl;
	}
}