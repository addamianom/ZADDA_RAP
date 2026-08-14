@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_ADDAP2
   as projection on ZI_ADDAP2
{
    key OrderNo,
    key ItemNo,
    TempitemNo,
    Product,
      @Semantics.amount.currencyCode : 'currencyunit'
    netamount,
    currencyunit,
    CreateBy,
    CreatedDatetime,
    LocalChangeddatetime,
    LocalLastchangedby,
    LastChangedby,
    LastChangedat,
    /* Associations */
    _Currency,
    _Header: redirected to parent ZC_ADDAH2
}
