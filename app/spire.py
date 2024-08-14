import pandas as pd
import json
import os
import zipfile
import tempfile

class VisTheSpire:
    def unzip_to_tempdir(zip_path):
        """
        take path to zipped 'runs' folder containing subfolders for each character's run data, put contents into a temporary directory to use in character data compilation
        """
        if os.path.splitext(zip_path)[1] != '.zip':
            raise ValueError('Not a zip file!')
        temp_dir = tempfile.mkdtemp()
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        if os.listdir(temp_dir)[0] != 'runs':
            print(os.listdir(temp_dir)[0])
            raise ValueError('Did you rename your run folder/zip file? Make sure your uncompressed folder is called "runs"')
        return f'{temp_dir}/runs' 
    def load_runs(character:str,dir_path:str) -> list:
        """
        Generate list of dictionaries containing all run data for a character.
        Args:
            character: character name in the following format: THE_SILENT,WATCHER,IRONCLAD,DEFECT
            dir_path: path to directory holding subfolders for each character's run data in json format
        Returns:
            List of dictionaries, each containing the complete run data for the specified character
        """
        char_run_dir = os.path.join(dir_path,character)
        run_list = os.listdir(char_run_dir)
        for run in run_list:
            if not run.endswith('json'):
                file_name = os.path.join(char_run_dir,run).split('.')[0]
                os.rename(os.path.join(char_run_dir,run),f'{file_name}.json')
                print('changed file type to json from',run.split('.')[-1])
        run_list = os.listdir(char_run_dir)
        runs = []
        for run in run_list:
            runs.append(json.load(open(os.path.join(char_run_dir,run))))
        return runs
    def compile_char_data(dir_path) -> pd.DataFrame:
        out = pd.DataFrame()
        for character in ['THE_SILENT','WATCHER','IRONCLAD','DEFECT']:
            runs = pd.DataFrame(load_runs(character,dir_path))
            out = pd.concat([out,runs]).reset_index(drop=True)
        return out.reset_index(drop=True)
    
    def __init__(self,zip_path):
        self.temp_dir = unzip_to_tempdir(zip_path)
        self.runs = compile_char_data(self.temp_dir)

    def death_freq(self) -> pd.DataFrame:
        counts = self.runs.groupby(['character_chosen','killed_by']).size().reset_index(name='count')
        total_counts = counts.groupby('character_chosen')['count'].transform('sum')
        counts['freq'] = (counts['count'] / total_counts)
        return counts

    