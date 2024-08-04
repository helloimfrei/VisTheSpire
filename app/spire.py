import pandas as pd
import json
import os

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

def compile_char_data(dir_path):
    out = pd.DataFrame()
    for character in ['THE_SILENT','WATCHER','IRONCLAD','DEFECT']:
        runs = pd.DataFrame(load_runs(character,dir_path))
        out = pd.concat([out,runs]).reset_index(drop=True)
    return out.reset_index(drop=True)

def filter_top_n_values(df, column_name, N):
    value_counts = df[column_name].value_counts()
    top_N_values = value_counts.nlargest(N).index
    return df[df[column_name].isin(top_N_values)]