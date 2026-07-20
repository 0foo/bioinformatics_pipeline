#!/bin/bash
set -e
trap 'echo "Error occurred at line $LINENO. Exiting..."' ERR

# --- Configuration ---
CACHE_DIR="/workspace/src_cache"
WORK_DIR="/workspace/drivers"
REPEATMASKER_DIR="/workspace/drivers/RepeatMasker"
FAMDB_TARGET="/workspace/drivers/RepeatMasker/Libraries/FamDB"
H5_WORK_DIR="/workspace/drivers/FamDB_Data"
EARLGREY_DIR="/workspace/drivers/EarlGrey"
RMBLAST_DIR="/workspace/drivers/rmblast"

echo "Wiping /workspace/drivers for fresh build..."
find /workspace/drivers -mindepth 1 -delete

echo "Setting up components from flat cache..."
mkdir -p "$FAMDB_TARGET" "$H5_WORK_DIR" "$REPEATMASKER_DIR" "$EARLGREY_DIR" "/workspace/drivers/bin" "$RMBLAST_DIR"

# Copy TRF and set permissions
cp /workspace/src_cache/trf /workspace/drivers/bin/trf
chmod +x /workspace/drivers/bin/trf

# Copy FamDB to the standard location and set permissions
cp -a /workspace/src_cache/famdb_repo/. "$FAMDB_TARGET/"
chmod +x "$FAMDB_TARGET/famdb.py"

# Copy EarlGrey and RMBlast
cp -a /workspace/src_cache/EarlGrey/. "$EARLGREY_DIR/"
cp -a /workspace/src_cache/rmblast/. "$RMBLAST_DIR/"

# Setup RepeatMasker
tar -xzf "$CACHE_DIR/RepeatMasker-4.2.4.tar.gz" -C "$REPEATMASKER_DIR/" --strip-components=1
chmod +x "$REPEATMASKER_DIR/RepeatMasker"

# --- Patching ---
# --- PATCHING ---
echo "Patching configurations..."
cd "$REPEATMASKER_DIR"

# 1. Force the FAMDB_DIR and FAMDB_DATA_DIR environment variables into the RepeatMasker script
# (The 'nuclear' patch ensures these variables propagate to child processes like famdb.py)
sed -i "1a BEGIN { \$ENV{'FAMDB_DIR'} = '/workspace/drivers/RepeatMasker/Libraries/FamDB'; \$ENV{'TRF_PRGM'} = '/workspace/drivers/bin/trf'; \$ENV{'FAMDB_DATA_DIR'} = '/workspace/drivers/FamDB_Data'; }" RepeatMasker

# 2. Patch famdb.conf and move it where famdb.py expects it
echo "Configuring famdb.conf..."
cd "$FAMDB_TARGET"
echo "[famdb]" > famdb.conf
echo "FAMDB_DATA_DIR = /workspace/drivers/FamDB_Data" >> famdb.conf
cd "$REPEATMASKER_DIR"

# 3. Update the config file
sed -i "/'FAMDB_DIR' => {/,/}/ s|'value' => '.*'|'value' => '/workspace/drivers/RepeatMasker/Libraries/FamDB'|" RepeatMaskerConfig.pm
sed -i "/'TRF_PRGM' => {/,/}/ s|'value' => '.*'|'value' => '/workspace/drivers/bin/trf'|" RepeatMaskerConfig.pm
sed -i "/'RMBLAST_DIR' => {/,/}/ s|'value' => '.*'|'value' => '/workspace/drivers/rmblast/bin'|" RepeatMaskerConfig.pm
sed -i "/'DEFAULT_SEARCH_ENGINE' => {/,/}/ s|'value' => '.*'|'value' => 'rmblast'|" RepeatMaskerConfig.pm

# Patch EarlGrey files
echo "Patching EarlGrey files..."

# Forcefully set the script directory inside the earlGrey script
# This searches for the variable definition and overwrites it with our absolute path
sed -i 's|my \$script_dir.*|my $script_dir = "/workspace/drivers/EarlGrey/scripts";|' "$EARLGREY_DIR/earlGrey"

# Clean up any legacy pathing attempts
sed -i '/SCRIPT_DIR=\/data\/toby/d' "$EARLGREY_DIR"/earlGrey

# Fix famdb.py paths
sed -i 's|famdb.py -i /opt/drivers/RepeatMasker/Libraries/FamDB |famdb.py -i /workspace/drivers/FamDB_Data/ |g' "$EARLGREY_DIR"/earlGrey*
sed -i 's|famdb.py -i $libpath|famdb.py -i /workspace/drivers/FamDB_Data/|g' "$EARLGREY_DIR"/earlGrey*

# Link H5 files
echo "Linking H5 files from cache to $H5_WORK_DIR..."
ln -s /workspace/src_cache/FamDB_Data_extracted/*.h5 "$H5_WORK_DIR/"

echo "Setup Complete."
touch /workspace/bioinformatics_pipeline/logs/setup.done