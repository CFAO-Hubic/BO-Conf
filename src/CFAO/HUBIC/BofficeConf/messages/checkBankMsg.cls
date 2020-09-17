Class CFAO.HUBIC.BofficeConf.messages.checkBankMsg Extends Ens.Response
{

Property bank As %String;

Property message As %String(MAXLEN = 1000);

Property status As %Integer;

Storage Default
{
<Data name="checkBankMsgDefaultData">
<Subscript>"checkBankMsg"</Subscript>
<Value name="1">
<Value>bank</Value>
</Value>
<Value name="2">
<Value>message</Value>
</Value>
<Value name="3">
<Value>status</Value>
</Value>
</Data>
<DefaultData>checkBankMsgDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
