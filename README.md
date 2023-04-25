[![Build Status](https://travis-ci.com/FlyBase/harvdev-perl-proforma-parser.svg?token=7Nvc5gEdzuNraK13EL3s&branch=master)](https://travis-ci.com/FlyBase/harvdev-perl-proforma-parser)
# harvdev-orig-proforma-parser
The original Perl proforma parser used by Harvdev.

The purpose of this repository is to make the original parser code more readily available for Docker, goCD, and for development of the new proforma parser.

**!!!This repository should be clean of passwriods etc **

- Files are obtained and updated from the Harvdev CVS location: `/fb_cvs/FB/modules/FlyBase-Proforma`
- As of now, this is a "one way" update of the original parser. In other words, changes from the CVS are pushed to GitHub but any GitHub changes **will not** be pushed back to CVS. Please **do not** edit this repository and expect the changes to be reflected at Harvdev.

## Use

The following environmental variables must be set when running the parser:

- `$PARSER_DATA_SOURCE`
  -  Format: `dbi:Pg:dbname=<database name>;host=<hostname>;port=<port>`
- `$PARSER_USER`
  - Format: `username`
- `$PARSER_PASSWORD`
  - Format: `password`
