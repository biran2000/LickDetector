%% User Input
ServerDir = 'U:\';
SaveDir = 'E:\Data\ResultsOngoing'
Mouse = 'EB017'
thisdate = '20220704'
thisses = '101'
nexample = 10;

%% Load DLC data (aligned to timeline)

load(fullfile(SaveDir,Mouse,datestr(datenum(thisdate,'yyyymmdd'),'yyyy-mm-dd'),thisses,'eyeCamLeftDLCOutput.mat'))
tmplicks = DLCOutput.tongue_likelihood;
tmptime = DLCOutput.Frame2Timeline;
tmplickx= DLCOutput.tongue_x;
tmplicky = DLCOutput.tongue_y;
spoutlocx = DLCOutput.watertube_x;
spoutlocy = DLCOutput.watertube_y;
spoutlikelikhood = DLCOutput.watertube_likelihood;
spoutpos = nanmean(cat(2,spoutlocx(spoutlikelikhood>0.9),spoutlocy(spoutlikelikhood>0.9)),1);
%% Load video frames
tmpvid = VideoReader(fullfile(ServerDir,Mouse,datestr(datenum(thisdate,'yyyymmdd'),'yyyy-mm-dd'),thisses,[datestr(datenum(thisdate,'yyyymmdd'),'yyyy-mm-dd') '_' thisses '_' Mouse '_eyeCamLeft.mj2']))

%% Detection threshold
figure; histogram(tmplicks,[0:0.1:1])
Threshold = 0.15;
PotentialLicks = find(tmplicks>Threshold);
% Distance to spout threshold
PotentialLicks(cell2mat(arrayfun(@(X) pdist2(spoutpos,cat(2,tmplickx(X),tmplicky(X))),PotentialLicks,'UniformOutput',0))>150) = [];
if any(PotentialLicks)
    PotentialLicks(([0; diff(PotentialLicks)])<5)=[];
    
    
    figure;
    imagesc(read(tmpvid,PotentialLicks(1)));
    colormap gray
    freezeColors
    hold on
    plot(spoutpos(1),spoutpos(2),'r*','MarkerSize',14)
    plot(tmplickx(PotentialLicks),tmplicky(PotentialLicks),'b*')
    xlim([0 tmpvid.Width])
    ylim([0 tmpvid.Height])
    set(gca,'ydir','reverse','XTick','','YTick','')
    title('All detected lick positions')
    %% Make GIF
    figure;
    filename = fullfile(SaveDir,Mouse,datestr(datenum(thisdate,'yyyymmdd'),'yyyy-mm-dd'),thisses,'LickDetection.gif'); % Specify the output file name
    countid=1;
    for idx = PotentialLicks'
        for idx2 = idx-5:idx+5
            if idx2>0 & idx2<length(tmplicks)
                % Read frame
                
                frame = read(tmpvid,idx2);
                h=imagesc(frame);
                colormap gray
                box off
                axis off
                
                hold on
                plot(spoutpos(1),spoutpos(2),'k*','MarkerSize',14)
                
                %             plot(tmplickx(PotentialLicks),tmplicky(PotentialLicks),'b*')
                
                if ismember(idx2,PotentialLicks)
                    plot(tmplickx(idx2),tmplicky(idx2),'r*','MarkerSize',14)
                    title([num2str(tmptime(idx2)) 's: Tongue detected'])
                else
                    title([num2str(tmptime(idx2)) 's: No tongue detected'])
                end
            end
            frame = getframe(gcf);
            im = frame2im(frame);
            [A,map] = rgb2ind(im,256);
            
            if countid == 1
                imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.1);
            else
                imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
            end
            pause(0.1)
            countid=countid+1;
        end
    end
else
    disp('No licks detected')
end
%% Just taking random 'fake potential licks' to make sure we didn't miss licks
PotentialLicks = find(tmplicks>quantile(tmplicks(:),0.95)&tmplicks<Threshold)
PotentialLicks = datasample(PotentialLicks,nexample,'replace',false);

figure;
filename = fullfile(SaveDir,Mouse,datestr(datenum(thisdate,'yyyymmdd'),'yyyy-mm-dd'),thisses,'LickDetection_ControlNoLickFrames.gif'); % Specify the output file name
countid=1;
for idx = PotentialLicks'
    for idx2 = idx-5:idx+5
        if idx2>0 & idx2<length(tmplicks)
            % Read frame
            
            frame = read(tmpvid,idx2);
            h=imagesc(frame);
            colormap gray
            box off
            axis off
            
            hold on
            plot(spoutpos(1),spoutpos(2),'k*','MarkerSize',14)
            
            %             plot(tmplickx(PotentialLicks),tmplicky(PotentialLicks),'b*')
            
            if tmplicks(idx2) > Threshold
                plot(tmplickx(idx2),tmplicky(idx2),'r*','MarkerSize',14)
                title([num2str(tmptime(idx2)) 's: Tongue detected'])
            else
                title([num2str(tmptime(idx2)) 's: No tongue detected'])
            end
        end
        frame = getframe(gcf);
        im = frame2im(frame);
        [A,map] = rgb2ind(im,256);
        
        if countid == 1
            imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',0.1);
        else
            imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',0.1);
        end
        pause(0.1)
        countid=countid+1;
    end
end

%% Frames to relabel
PotentialLicks = find(tmplicks>quantile(tmplicks(:),0.95));
disp(['Frames to look at: '])
sort(datasample(PotentialLicks,nexample))