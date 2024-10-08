import pandas as pd
import json
import os
import zipfile
import tempfile
import itertools

class VisTheSpire:
    pretty_names = {'THE_SILENT':'The Silent','WATCHER':'Watcher','IRONCLAD':'Ironclad','DEFECT':'Defect'}
    @staticmethod
    def make_hierarchy_table(df: pd.DataFrame, parent_col: str, child_col: str, size_col: str) -> pd.DataFrame:
        """
        Take a dataframe with some parent column (e.g. character chosen), some child value (e.g. killed by), and some size/count column (e.g. frequency of deaths) and make it into a hierarchy table for treemaps. See plotly treemap documentation for more info.
        Args:
            df: dataframe with columns for parent, child, and size
            parent_col: name of column in df that holds parent values (the highest level of the hierarchy that contains children specified in child_col)
            child_col: name of column in df that holds child values (these values each become a sector inside their respective parent with size specified in size_col)
            size_col: name of column in df that holds size value (a value that is used to determine the size of each sector in the treemap)
        Returns:
            Dataframe with columns for parent, child, and size, ready for use in a plotly treemap.
        """
        unique_parents = df[parent_col].unique()
        out = df[[parent_col,child_col,size_col]].rename(columns={parent_col:'parent',child_col:'child',size_col:'size'})
        out['pretty_labels'] = out.child
        out.child = out.child + '+' + out.parent

        parent_rows = pd.DataFrame({'parent':0,'child':unique_parents,'size':0})
        out = pd.concat([parent_rows,out]).reset_index(drop=True)
        return out
    
    def __init__(self,zip_path):
        self.zip_path = zip_path
        self.temp_dir = self.unzip_to_tempdir()
        self.runs = self.compile_char_data()
        self.filtered_runs = self.runs

    def filter_master_runset(self,changes:dict) -> pd.DataFrame:
        """
        DOES NOT WORK RIGHT NOW. NEED TO REVISIT AT A LATER TIME
        Filter the master runs dataframe and update the filtered_runs instance attribute.
        Args:
            changes: dictionary where each key is a column names and each value is a list of column values to filter on.
        Returns:
            None
        """
        filtered = self.runs.copy()
        for column,values in changes.items():
            try:
                #required for wacky R feature of converting lists of length 1 to their respective datatypes. annoying for python integration!
                if type(values) == str: 
                    changes = list(changes)
                if len(changes) == 0 or changes is None: 
                    print(f'No filtering completed. Value for {column} must be a string or list of values')
                    break
                filtered = filtered[filtered[column].isin(values)]
            except KeyError:
                raise KeyError(f'Could not find column {column} in dataframe')
        self.filtered_runs = filtered

    def unzip_to_tempdir(self) -> str:
        """
        Take path to zipped 'runs' folder containing subfolders for each character's run data, put contents into a temporary directory to use in character data compilation.
        Args:
            None
        Returns:
            String of path to temporary directory containing zipped 'runs' folder
        """
        if os.path.splitext(self.zip_path)[1] != '.zip':
            raise ValueError('Not a zip file!')
        temp_dir = tempfile.mkdtemp()
        with zipfile.ZipFile(self.zip_path, 'r') as zip_ref:
            zip_ref.extractall(temp_dir)
        if os.listdir(temp_dir)[0] != 'runs':
            print(os.listdir(temp_dir)[0])
            raise ValueError('Did you rename your run folder/zip file? Make sure your uncompressed folder is called "runs"')
        return f'{temp_dir}/runs' 
 
    def load_runs(self,character:str) -> list:
        """
        Generate list of dictionaries containing all run data for a character.
        Args:
            character: character name in the following format: THE_SILENT,WATCHER,IRONCLAD,DEFECT
            dir_path: path to directory holding subfolders for each character's run data in json format
        Returns:
            List of dictionaries, each containing the complete run data for the specified character
        """
        char_run_dir = os.path.join(self.temp_dir,character)
        run_list = os.listdir(char_run_dir)
        for run in run_list:
            if not run.endswith('json'):
                file_name = os.path.join(char_run_dir,run).split('.')[0]
                os.rename(os.path.join(char_run_dir,run),f'{file_name}.json')
                #print('changed file type to json from',run.split('.')[-1])
        run_list = os.listdir(char_run_dir)
        runs = []
        for run in run_list:
            runs.append(json.load(open(os.path.join(char_run_dir,run))))
        return runs

    def compile_char_data(self) -> pd.DataFrame:
        """
        Generate a master dataframe of all run data contained in the output of the load_runs method (big list of dictionaries).
        Args:
            None
        Returns:
            Master dataframe of all run data, with one row for each run.
        """
        out = pd.DataFrame()
        for character in ['THE_SILENT','WATCHER','IRONCLAD','DEFECT']:
            runs = pd.DataFrame(self.load_runs(character))
            out = pd.concat([out,runs]).reset_index(drop=True)
        return out.reset_index(drop=True)

    def death_freq(self) -> pd.DataFrame:
        """
        Generate a dataframe containing frequencies of deaths caused by different enemies, for each character.
        Args:
            None
        Returns:
            Dataframe with columns for character_chosen, killed_by, count, and freq 
        """
        counts = self.runs.groupby(['character_chosen','killed_by']).size().reset_index(name='count')
        total_counts = counts.groupby('character_chosen')['count'].transform('sum')
        counts['freq'] = (counts['count'] / total_counts)
        return counts

    def stat_summary(self,character:str) -> pd.DataFrame:
        """
        Generate a dataframe containing total wins, total losses, and win rate for a specified character.
        NOTE: The output of this method is meant to be used solely as a displayable table in Shiny, the column names (character, and ' ') are just for easy display.
        Args:
            character: one of the four following characters: THE_SILENT,WATCHER,IRONCLAD,DEFECT
        Returns:
            Dataframe with character stats to be used as a Shiny display table.
        """
        filtered = self.runs[self.runs.character_chosen == character]
        total_runs = len(filtered)
        if total_runs == 0:
            return pd.DataFrame({self.pretty_names.get(character,'unknown character!'):['total_runs','wins','losses','win_rate'],' ':['No data found','No data found','No data found','No data found']})
        wins = len(filtered[filtered.victory == True])
        losses = len(filtered[filtered.victory == False])
        win_rate = wins / total_runs
        return pd.DataFrame({self.pretty_names.get(character,'unknown character!'):['total_runs','wins','losses','win_rate'],' ':[total_runs,wins,losses,win_rate]})
    
    def items_at_event(self,click:str,item_type:str, event_type:str) -> pd.DataFrame:
        """
        Generate a dataframe containing the most common items for a specified event type, for a given character. Intended for use with Shiny click event.
        Args:
            click: Input from a user on a Shiny treemap representing the clicked child sector of a treemap (e.g. 'Slime Boss+THE_SILENT'). See make_heirarchy_table() for how the id of children are generated
            item_type: Column in runs dataframe containing lists of items for a given run (row) (relics, master_deck, etc.)
            event_type: Column in runs dataframe containing event type (e.g. 'killed_by','floor_reached,'ascencsion_level' etc.)
        Returns:
            Dataframe with columns for item_type and frequency at given event (size)
        """
        event_option,character = click.split('+')[0],click.split('+')[1]
        nested_items = self.runs.query(f'{event_type} == "{event_option}" & character_chosen == "{character}"')[item_type].tolist()
        all_items = list(itertools.chain(*nested_items))
        freqs = pd.DataFrame({item_type:all_items}).groupby(item_type,as_index=False).size()
        return freqs