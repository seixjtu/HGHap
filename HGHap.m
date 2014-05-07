clc
clear
Mpath='Benchmark Data File Path\SurveyDataset\exp-100\'; %one can change the file path and file name(for one length value).
directory=[Mpath,'*-h0.7'];
D1=dir(directory); 
if isempty(D1)
    fprintf(['ERROR! Fail to find ',Mpath,'\n']);
    return;
end
Num_paras=length(D1);
for d=1:Num_paras    %for each parameter set
    D=dir([Mpath,D1(d).name,'\*.m.4.err']); 
    if isempty(D)
            fprintf('ERROR! Fail to find %s *.m.4.err!\n',D1(d).name);
            return;
    end
    fprintf('Succeed to find %s \\*.m.4.err!\n',D1(d).name);
    Num_exps=length(D);
    rrs=zeros(1,Num_exps);
    for i=1:Num_exps  %for each instance
        [M0,m0,n0,H_real]=inputdata(Mpath,D1(d).name,D(i).name,i); 
        [M,m,n,H_assem,Most]=Heter4to2(M0,m0,n0); 
        K=5;  %  parameter k in the SkNN, one can change it.
        C=2;   %  parameter cs the support count threshold, one can change it.
        sss=D1(d).name;
        RNNname=KNN2(M,m,n,K,i,sss);     
        system(['fpgrowth.exe -tm -s-',num2str(C),' ',RNNname,' ',RNNname,'.out']); %Call an external executable file fpgrowth.exe
        fid_RNNout=fopen([RNNname,'.out'],'r');
        fid_graph=fopen([num2str(i),sss,'.Graph'],'w+');
        fprintf(fid_graph,'                             \n');
        NUMedge=0; 
        while ~feof(fid_RNNout)
            tline=fgetl(fid_RNNout);
            index=strfind(tline,'(');
            newtline=[tline(index+1:end-1),' ',tline(1:index-2),'\n'];
            fprintf(fid_graph,newtline);
            NUMedge=NUMedge+1;
        end
        frewind(fid_graph);
        fprintf(fid_graph,'%d %d 1',NUMedge,m);
        fclose(fid_RNNout);
        fclose(fid_graph);
        Nparts=2;
        UBfactor=1;
        Nruns=10;  %default:10 range:1...10
        CType=5;   %default:1  range:1...5
        RType=3;   %default:1  range:1...3
        Vcycle=1;  %default:1  range:1...3
        Reconst=0; %default:0  range:0...1
        dbglvl=0; %range:0 or 24
        system(['hmetis ',num2str(i),sss,'.Graph ',num2str(Nparts),' ',num2str(UBfactor),' ',num2str(Nruns),' ',num2str(CType),' ',num2str(RType),' ',num2str(Vcycle),' ',num2str(Reconst),' ',num2str(dbglvl)]);
        %Call an external executable file hmetis. e.g. hmetis 1.Graph 2 1 10 1 1 1 0 24
        P=load([num2str(i),sss,'.Graph.part.2']);
        P=[P 1-P];
        H_assem=GetWholeHap(M,P,H_assem); 
        H_assem4=H_assem2to4(H_assem,Most);
        rrs(i)=RR4(H_real,H_assem4);       
        fprintf('The instance %d is finished!\n',i);   
    end %end for each instance       
    fid=fopen([D1(d).name,'_RR.txt'],'w+'); 
    for j=1:Num_exps
        fprintf(fid,'%d\t%1.4f\n',j,rrs(j));  
    end    
    average_rr=mean(rrs);
    fprintf(fid,'%1.4f\n\n',average_rr);
    fclose(fid);
end %end for each parameter set
fprintf('one paramenter set of one length value ends£¡');





