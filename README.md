# chandl

Download all images and videos from 4chan thread.

## Usage

chandl [required&optional-params]

## Options

| parameter                | type   | default  | description                     |
| ------------------------ | ------ | -------- | ------------------------------- |
| -h, --help               |        |          | print this cligen-erated help   |
| --help-syntax            |        |          | advanced: prepend,plurals,..    |
| -v, --videosOnly         | bool   | false    | download videos only.           |
| -i, --imagesOnly         | bool   | false    | download images only.           |
| -m=, --maxConcurrentDls= | int    | 1        | set maximum parallel downloads. |
| -d=, --dir=              | string | "./"     | set download directory.         |
| -l=, --link=             | string | REQUIRED | thread link                     |
