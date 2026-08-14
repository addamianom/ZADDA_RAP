@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'position'
@Metadata.ignorePropagatedAnnotations:true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define  view entity ZI_ADDAP2
  as select from zaddap1
  association     to parent ZI_ADDAH2 as _Header   on $projection.OrderNo = _Header.OrderNo

  association [1] to I_Currency       as _Currency on $projection.currencyunit = _Currency.Currency

{
  key order_no              as OrderNo,
  key item_no               as ItemNo,
      tempitem_no           as TempitemNo,
      product               as Product,
      @Semantics.amount.currencyCode : 'currencyunit'
      net_amount            as netamount,
      currency_unit         as currencyunit,
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
      _Currency,
      _Header
        
}
