FROM flybase/harvdev-docker:latest

WORKDIR /src

RUN mkdir /output

ENV PERL5LIB=/src/lib/perl5

ADD . .

CMD ["perl", "new_proforma.pl", "-d", "/proforma/input/*", "/proforma/output/test_out.xml"]
