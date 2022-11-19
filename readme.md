# Quick backup + restore GIT repositories

Quickly backup and restore any GIT repository with or without LFS files.


# Clone
```
git clone git@github.com:rboonzaijer/git-backups.git

cd git-backups

# Make files executable
chmod +x *.sh
```

# Backup
without LFS files
```
./backup.sh {existing_repository_url} ~/my_backup.tar.gz
```

including LFS files
```
./backup_lfs.sh {existing_repository_url} ~/my_backup.tar.gz
```

# Restore
without LFS files
```
./restore.sh ~/my_backup.tar {empty_repository_url}
```
including LFS files
```
./restore_lfs.sh ~/my_backup.tar.gz {empty_repository_url}
```
