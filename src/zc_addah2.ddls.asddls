
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'projection'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_ADDAH2
  provider contract transactional_query as projection on ZI_ADDAH2
{
    key OrderNo,
    OrderType,
    Customer,
      @Semantics.amount.currencyCode : 'currencyunit'
    GrossAmt,
    CurrencyUnit,
    CreateBy,
    CreatedDatetime,
    LocalChangeddatetime,
    LocalLastchangedby,
    LastChangedby,
    LastChangedat,
    /* Associations */
    _position: redirected to composition child ZC_ADDAP2

}
