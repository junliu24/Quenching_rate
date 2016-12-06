clear
load blank_temperature.mat
format long
critical_Ti=492; %% Blank temperature after being transfered to tool (transfer time about 8 s)
critical_Tm=340;  %% CCT curve precipitation start temperature
critical_Tf=250;  %% precipitation ending temperature
critical_qunching_rate1=-35;
critical_qunching_rate2=-18;
critical_tm=(critical_Tm-critical_Ti)/critical_qunching_rate1;
critical_tf=(critical_Tf-critical_Tm)/critical_qunching_rate2+critical_tm;

k1=critical_qunching_rate1;
k2=critical_qunching_rate2;
b1=critical_Ti;
b2=critical_Tm;

time_FE1=[0:stages_of_stamping-1]/stages_of_stamping*(Stroke/Forming_speed);
time_FE2=[1:stages_of_qunching-1]+(Stroke/Forming_speed);
time_FE=[time_FE1, time_FE2];

xdata1=linspace(0,critical_tm,50);
ydata1=k1.*xdata1+b1;
xdata2=linspace(critical_tm,critical_tf,50);
ydata2=k2.*(xdata2-critical_tm)+b2;
xdata3=linspace(critical_tf,time_FE(end),50);
ydata3=xdata3.*0+critical_Tf;
xdata2(1)=[];
ydata2(1)=[];
xdata3(1)=[];
ydata3(1)=[];
fit0=fit([xdata1 xdata2 xdata3]',[ydata1 ydata2 ydata3]','linearinterp');
Critical_temperature=fit0(time_FE);

Tdata=zeros(element_number,length(time_FE));
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
%plot(time_FE,Critical_temperature,'*r')
ylim([0,Max_T+30])
title('All Elements')
hold off
%---------------------------------------------

figure
hold on
Critical_temperature=Critical_temperature';
Filter_ele=ones(element_number,1);
for i=1:element_number
    if sum(Tdata(i,:)>Critical_temperature)~=0
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

%-------------------------------------------------------------------
    ccc=blank_elem_no;
    ppp=double(Filter_ele);
    cc=[ccc,ppp];
    save point1.txt cc -ascii;
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
