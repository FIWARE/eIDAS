# Test eIDAS Certificate Chain

Script to create a certificate chain with self-signed CA where the client certificate is compliant with the [standard](https://www.etsi.org/deliver/etsi_en/319400_319499/31941203/01.02.01_60/en_31941203v010201p.pdf).

## How to use

Build the docker image with

```
   docker build . -t eidas:latest
```

Run it and mount local output folder
```
   docker run --mount type=bind,source="$(pwd)"/output,target=/out --name eidas eidas:latest 
```

The subject of the client certificate can be configured by mounting a [config file](script%2Fconfig) as followed

```
    docker run --mount type=bind,source="$(pwd)"/config,target=/config/config --name eidas eidas:latest 
```


## Requirements
### Subject

The subject must contain at least
- countryName (the country in which the subject (legal person) is established)
- organizationName (the full registered name of the subject (legal person))
- organizationIdentifier
- commonName (name commonly used by the subject to represent itself)

The organizationIdentifier must be generated using the following schema based on [ETSI EN 319 412-1](https://www.etsi.org/deliver/etsi_en/319400_319499/31941201/01.04.02_20/en_31941201v010402a.pdf):

    When the legal person semantics identifier is included, any present organizationIdentifier attribute in the subject field shall contain information using the following structure in the presented order:

        3 character legal person identity type reference
        2 character ISO 3166 [2] country code
        hyphen-minus "-" (0x2D (ASCII), U+002D (UTF-8)) and
        identifier (according to country and identity type reference)

    The three initial characters shall have one of the following defined values:

        VAT for identification based on a national value added tax identification number.
        NTR for identification based on an identifier from a national trade register.
        PSD for identification based on the national authorization number of a payment service provider under Payments Services Directive (EU) 2015/2366 [i.13]. This shall use the extended structure as defined in ETSI TS 119 495 [3], clause 5.2.1.
        LEI for a global Legal Entity Identifier as specified in ISO 17442 [4]. The 2 character ISO 3166 [2] country code shall be set to 'XG'.
        Two characters according to local definition within the specified country and name registration authority, identifying a national scheme that is considered appropriate for national and European level, followed by the character ":" (colon).

    Other initial character sequences are reserved for future amendments of the present document. In case "VAT" legal person identity type reference is used in combination with the "EU" transnational country code, the identifier value should comply with Council Directive 2006/112/EC [i.12], article 215.


### QcStatement

Certificates require fields defined in [etsi](https://www.etsi.org/deliver/etsi_en/319400_319499/31941205/02.01.01_60/en_31941205v020101p.pdf) to claim compliance with the EU legislation. The standard is based on [RFC3739](https://datatracker.ietf.org/doc/html/rfc3739#section-3.2.6).

Two statements are mandatory:
- esi4-qcStatement-1 ( OID 0.4.0.1862.1.1 )


    This statement is a statement by the issuer that this
    certificate is issued as a Qualified Certificate according
    Annex I and II of the Directive 1999/93/EC of the European Parliament
    and of the Council of 13 December 1999 on a Community framework
    for electronic signatures, as implemented in the law of the country
    specified in the issuer field of this certificate.

- esi4-qcStatement-5 ( OID 0.4.0.1862.1.5 )


    This statement holds URLs to PKI Disclosure Statements (PDS) in accordance 
    with Annex A of ETSI EN 319 411-1.

Additionally esi4-qcStatement-6 ( OID 0.4.0.1862.1.6 ) is used to define the role/usage of the certificate (signatures, seals, web auth).

The values can be configured in the [config file](script/openssl-client.cnf)


## Alternatives considered

- https://medium.com/bunq-developers-corner/sdk-update-connect-and-authorize-as-a-psd2-user-in-10-minutes-2516a87d796b -> uses their server for the ca
