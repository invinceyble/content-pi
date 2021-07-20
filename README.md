# content-pi
🍓 Scripts to setup my Raspberry Pi as a NAS and media server

Some notes:
- I ran this on a Raspberry Pi 2B, with 1GB RAM and an 8GB microSD card. The performance seems to be _acceptable_ (mostly 720 and 1080p video files). 
- I'm keeping this server completely local, and not exposing it to the internet because I don't want to deal with the security implications.
- I did this for the lols. I bought a new Macbook recently that only has USB-C ports, which makes it annoying to connect my existing USB-A hard drives. I also had a bunch of media I didn't want to store on my computer's SSD (which is way too small), nor did I want to store it in the cloud. It seemed handy to store it somewhere that I can access it from any of my devices at home.

## Equipment

- Raspberry Pi 2B, with 1GB RAM and an 8GB microSD card
- MyPassport 1TB external hard drive
- Ethernet cable
- USB keyboard & mouse
- HDMI cable and monitor
- D-Link DWA-182 Wifi Dongle (optional)

## Installation

1. Install Raspberry Pi OS onto the microSD card. ([Source](https://projects.raspberrypi.org/en/pathways/getting-started-with-raspberry-pi))

    Download the [Raspberry Pi Imager](https://www.raspberrypi.org/software/), then install Raspberry Pi OS onto the microSD card. Plug it into the Pi, then boot it up.

1. Setup Jellyfin ([Source](https://www.wundertech.net/how-to-setup-jellyfin-on-a-raspberry-pi/))

    I formatted my hard drive as exFAT using Disk Utility on macOS. 

    * Mount the external hard drive on boot
    * Install Jellyfin 

1. Enable SSH access ([Source](https://www.raspberrypi.org/documentation/remote-access/ssh/))

    I did it from the Desktop, rather than the CLI.

1. Set a static IP address ([Source](https://pimylifeup.com/raspberry-pi-static-ip-address/))

1. Setup a NAS (Network Attached Storage) using the AFP protocol ([Source](https://pimylifeup.com/raspberry-pi-afp/))

    My personal computer is a Macbook, so I went with creating a NAS using the AFP protocol. Next time, I'll probably use [Samba](https://pimylifeup.com/raspberry-pi-samba/) instead, which seems to be more popular overall.

    At this point, I can read from the external hard drive plugged into the pi from my own computer. However, I cannot write to it.

1. Give `pi` user write access to the hard drive.

    I edited the `/etc/fstab` file:    
    ```
    UUID=60F5-98D7	/mnt/media	exfat	defaults,uid=pi,gid=pi,umask=0022,nofail	0   2
    ```

    Taking a closer look at the mount options:

    - `defaults`: Use the default options: `rw`, `suid`, `dev`, `exec`, `auto`, `nouser`, and `async`.
    - `nofail`: Allow the pi to boot up, even if the hard drive is not attached
    - `uid`: Set the owner of the drive to "pi" user
    - `gid`: Set the group of the drive to "pi" user
    - `umask=0022`: Only the user has rwx permissions. Groups and Other have r permissions only.

1. Change the hostname from `raspberrypi.local` to `mediaserver.local` ([Source](https://www.howtogeek.com/167195/how-to-change-your-raspberry-pi-or-other-linux-devices-hostname/))

    The instructions say to run `sudo /etc/init.d/hostname.sh` after the changes. This file did not existing on my pi. I skipped this step and everything was still fine.

## Notes

### SSH

After the initial setup and I've started the Pi in headless mode, I prefer to run commands from my personal computer by ssh-ing in. 

```bash
ssh pi@static.ip
```

### Formatting hard drive as HFS+

I initially formatted my hard drive as HFS+, but ran into a lot of trouble with enabling write access to the `pi` user.

The following generally worked, until I started getting input/output failures, presumably from my terrible decision to disable then enable Journaling.

[This forum post](https://www.raspberrypi.org/forums/viewtopic.php?p=1483045#p1483045) was the thing that got everything working:

```bash
sudo apt-get install hfsprogs
```

I edited the `/etc/fstab` file:    
```
UUID="zzz"	/media/hfsdisk  hfsplus defaults,uid=1000,force,rw,nofail    0   2
```

Finally, I changed the ownership.
```bash
sudo chown pi:pi /mnt/media
```

### `umask` vs `chmod`

`umask` sets file permissions for newly created files. It's run at a process-level, so not on any specific file.

`chomd` changes permissionsn for existing files.
