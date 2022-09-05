In almost all the routines the value of the registers that are not part of the
output are pushed to the stack before they are modified.

## LBA to CHS

```
sector      = (LBA % sectors_per_track) + 1
head        = (LBA / sectors_per_track) % heads_per_cylinder
cylinder    = (LBA / sectors_per_track) / heads_per_cylinder
```

### In `boot.asm` file

- routine `lba_to_chs`

  params:

  - ax - LBA address

  returns

  - cx [0-5 bits] - sector
  - cx [6-15 bits] - cylinder
  - dh - head

  The returns are places in the exact registers that BIOS expects the values to be,
  when the interrupt is called.

  - How the cx register stores the values for the cylinder and the sector

  ```
  CX =          ---CH--- ---CL---
  cylinder:     23455633 23
  sector:                  453212
  ```

- routine `disk_read`
  params
  - ax - lba
  - cl - number of sectors to read (128 max)
  - dl - drive number
  - es:bx - memory location to store the data

## Reading from the disk

- INT 13,2

ah = 02
al = number of sectors to read
ch = cylinder
cl = sector number
dh = head number
dl = drive number (0 = A:, 1 = 2nd Floppy, 80h = drive 0, 81h = drive 1)
es:bx = pointer to buffer

returns:
ah = status
al = number of sectors read
cf = 0 if successful
= 1 if error

## FAT file system

- https://wiki.osdev.org/FAT

```
+----------+------------+-------------+----------+
| RESERVED |   FAT's    |  ROOT DIR   |   DATA   |
+----------+------------+-------------+----------+
```

- #### The root dir

```
+-----------+-------+-------------+----------+-----------+--------+----------------+--------+-------+--------------+-------+
| File name | Attr. | Creation    | Creation | Creation  | Access |     First      |  Mod.. | Mod.. |     First    | Size  |
|           |       | Time (1/10s)| Time     |   Date    |  Date  | Cluster (High) |  Time  | Date  | Cluster (Low)|       |
+-----------+-------+-------------+----------+-----------+--------+----------------+--------+-------+--------------+-------+
```

- #### Some notes
  - FAT12 - each entry has 12 bits
  - A directory entry is 32 bytes
  - all file names in the FAT12 FS are 11 bytes long
  - we only care about the 'Low' First Cluster
  - The cluster number in the data region starts from 2

```
fat_region_size         = fat_count * sectors_per_fat
root_dir_sector(start)  = reserved + fat_region_size
root_dir_size           = (dir_entry_count(224) * 32 + bytes_per_sector - 1) \ bytes_per_sector
lba (of the file begin) = data_region_begin + (cluster_no - 2) * sectors_per_cluster




```
