@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'header'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_ADDAH2
  as select from zaddah1
  composition [0..*] of ZI_ADDAP2 as _position
{


  key order_no              as OrderNo,
      order_type            as OrderType,
      customer              as Customer,
      @Semantics.amount.currencyCode : 'CurrencyUnit'
      gross_amt             as GrossAmt,
      currency_unit         as CurrencyUnit,
      @Semantics.user.createdBy: true
      create_by             as CreateBy,
      @Semantics.systemDateTime.createdAt: true
      created_datetime      as CreatedDatetime,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_changeddatetime as LocalChangeddatetime,
      @Semantics.user.localInstanceLastChangedBy: true
      local_lastchangedby   as LocalLastchangedby,
      @Semantics.user.lastChangedBy: true
      last_changedby        as LastChangedby,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changedat        as LastChangedat,
      _position

}

