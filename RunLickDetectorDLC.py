# When in deeplabcut environment, in ipython

import deeplabcut
config_path = r'C:\Users\EnnyB\Documents\GitHub\LickDetector\config.yaml' #Change path. Don't forget to change 'Project_path' in the config file.
videos = [] # This can a list of (paths to) videos
    
deeplabcut.analyze_videos(config_path,videos,save_as_csv=False)
deeplabcut.analyze_videos_converth5_to_csv(videos, videotype=".mj2",listofvideos=True)

# Optional --> Check labels
#deeplabcut.create_labeled_video(config_path,videos,track_method = "skeleton")
#deeplabcut.plot_trajectories(config_path,videos,showfigures=True,track_method="skeleton")

#Optional --> Retrain the network
#deeplabcut.add_new_videos(config_path,videos)
# If necessary, change videopath
#deeplabcut.extract_outlier_frames(config_path,videos,outlieralgorithm='manual')
#deeplabcut.refine_labels(config_path)
#deeplabcut.merge_datasets(config_path)
#deeplabcut.check_labels(config_path)
#deeplabcut.create_training_dataset(config_path)
#deeplabcut.train_network(config_path)
#deeplabcut.evaluate_network(config_path,plotting=True)




