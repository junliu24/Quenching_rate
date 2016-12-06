clear
prompt={'Number of stages for stamping:','Numer of stage for qunching','Forming speed','Stroke'};
dlg_title='Input';
defaultans={'11','11','250','25'};
answer=inputdlg(prompt,dlg_title,1,defaultans);
stages_of_stamping=str2double(answer{1});
stages_of_qunching=str2double(answer{2});
Forming_speed=str2double(answer{3});
Stroke=str2double(answer{4});

tic
   dataname=strcat('Qtemperature_1.asc');
   data=importdata(dataname,' ',9);
   value_of_data=data.data(:,1);
   value_of_data(end,:)=[];     
   blank_elem_no=value_of_data;
   element_number=size(value_of_data,1);
   x=1
   for n=1:stages_of_stamping
       dataname=strcat('temperature_',num2str(n),'.asc');
       data=importdata(dataname,' ',9);
       value_of_data=data.data(:,2);
       value_of_data(end,:)=[];     
       blank_temperature(x,1)={value_of_data};
       x=x+1
   end
   for n=2:stages_of_qunching
       dataname=strcat('Qtemperature_',num2str(n),'.asc');
       data=importdata(dataname,' ',9);
       value_of_data=data.data(:,2);
       value_of_data(end,:)=[];     
       blank_temperature(x,1)={value_of_data};
       x=x+1
   end
   steps=x-1;
   save (['blank_temperature.mat'], 'blank_temperature','steps',...
       'Forming_speed','Stroke','blank_elem_no','element_number',...
       'stages_of_stamping','stages_of_qunching');
toc
