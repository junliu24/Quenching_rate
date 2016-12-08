clear
tic
load blank_temperature.mat
format long
prompt2={'Initial T','t1','T1','t2','T2'};
dlg_title2='Input';
defaultans2={'490','4','350','9','250'};
answer0=inputdlg(prompt2,dlg_title2,1,defaultans2);
cT0=str2double(answer0{1});
ct1=str2double(answer0{2});
cT1=str2double(answer0{3});%% CCT curve precipitation start temperature
ct2=str2double(answer0{4});
cT2=str2double(answer0{5});%% precipitation ending temperature 

time_FE1=[0:stages_of_stamping-1]/stages_of_stamping*(Stroke/Forming_speed);
time_FE2=[1:stages_of_qunching-1]+(Stroke/Forming_speed);
time_FE=[time_FE1, time_FE2];

QR1=-(cT0-cT1)/ct1
QR2=-(cT1-cT2)/(ct2-ct1)
xdata1=linspace(0,ct1,20);
ydata1=QR1.*xdata1+cT0;
xdata2=linspace(ct1,ct2,20);
ydata2=QR2.*(xdata2-ct1)+cT1;
xdata3=linspace(ct2,time_FE(end),20);
ydata3=xdata3.*0+cT2;
xdata2(:,1)=[];
ydata2(:,1)=[];
xdata3(:,1)=[];
ydata3(:,1)=[];
fit0=fit([xdata1 xdata2 xdata3]',[ydata1 ydata2 ydata3]','linearinterp');
Critical_temperature=fit0(time_FE);
Tdata=zeros(element_number,steps);
for i=1:steps
    Tdata(:,i)=blank_temperature{i,1};
end

figure
hold on
Max_T=max(Tdata(:,1));
for i=1:element_number
    T_mod=Tdata(i,:);
    plot(time_FE,T_mod,'-')
end
plot(fit0,'*r')
%-----------------------------------------
ylim([0,Max_T+30])
title('All Elements')
hold off
%---------------------------------------------
t1_step2=max(find(sort([time_FE,ct1])==ct1));
t1_step1=t1_step2-1;
t2_step2=max(find(sort([time_FE,ct2])==ct2));
t2_step1=t2_step2-1;
t1_t1=time_FE(t1_step1);
t1_t2=time_FE(t1_step2);
t2_t1=time_FE(t2_step1);
t2_t2=time_FE(t2_step2);

figure
hold on
Filter_ele=ones(element_number,1);
for i=1:element_number
    t1_T1=Tdata(i,t1_step1);
    t1_T2=Tdata(i,t1_step2);
    T1=((t1_T2-t1_T1)/(t1_t2-t1_t1)*(ct1-t1_t1)+t1_T1);
    t2_T1=Tdata(i,t2_step1);
    t2_T2=Tdata(i,t2_step2);
    T2=((t2_T2-t2_T1)/(t2_t2-t2_t1)*(ct2-t2_t1)+t2_T1);
    if T1>cT1 | T2>cT2
        Filter_ele(i)=0;
    else
    T_mod=Tdata(i,:);
    plot(time_FE,T_mod,'-')
    end
end
plot(fit0,'*r')
ylim([0,Max_T+30])
title('Safe Elements')
hold off
toc
disp('contour result output...');

%%
    ccc=blank_elem_no;
    ppp=double(Filter_ele);
    cp=[ccc,ppp];
    save point1.txt cp -ascii;
            filename='results2.asc';
            fileID = fopen('Qtemperature_1.asc');
            tline = fgetl(fileID);
            dlmwrite(filename,tline,'delimiter','');
            for n1=1:8
                disp(tline);
                tline = fgetl(fileID);
                dlmwrite(filename,tline,'-append','delimiter','','newline','pc');
            end
            fclose(fileID);
            fileID = fopen('point1.txt');
            tline = fgetl(fileID);
            dlmwrite(filename,tline,'-append','delimiter','','newline','pc');
            while ischar(tline)
                tline = fgetl(fileID);
                dlmwrite(filename,tline,'-append','delimiter','','newline','pc');
            end
            fclose(fileID);    
    delete 'point1.txt'
disp('finish')
toc
