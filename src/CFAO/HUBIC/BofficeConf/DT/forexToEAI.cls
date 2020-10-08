Class CFAO.HUBIC.BofficeConf.DT.forexToEAI Extends Ens.DataTransformDTL [ DependsOn = (CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch, CFAO.HUBIC.BofficeConf.Table.JrnForexTab) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch' targetClass='CFAO.HUBIC.BofficeConf.tables.forexBatch' create='new' language='objectscript' >
<annotation>Enregistrement des données issus du journal Forex pour le flux Bo Conf</annotation>
<foreach property='source.Records()' key='k1' >
<assign value='source.Records.(k1).%Source' property='target.forexRecords.(k1).forexFileName' action='set' />
<assign value='source.Records.(k1).IDforex' property='target.forexRecords.(k1).idForex' action='set' />
<assign value='..SubString(source.Records.(k1).TRADEDATE,1,10)' property='target.forexRecords.(k1).tradeDate' action='set' />
<assign value='source.Records.(k1).CPTYSHORTNAME' property='target.forexRecords.(k1).bank' action='set' />

<assign value='source.Records.(k1).TRADETYPESHORTNAME' property='target.forexRecords.(k1).tradeType' action='set' />


<assign value='..replace(target.forexRecords.(k1).amountReceived," ","")' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='source.Records.(k1).CLIENTRATE' property='target.forexRecords.(k1).term' action='set' />

<assign value='source.Records.(k1).SPOTRATE' property='target.forexRecords.(k1).spot' action='set' />
<assign value='source.Records.(k1).REMAININGAMOUNT1' property='target.forexRecords.(k1).amountReceivedRemaining' action='set' />
<assign value='source.Records.(k1).APPLICATIVESTATUSNAME' property='target.forexRecords.(k1).forexStatus' action='set' />
<assign value='source.Records.(k1).REFERENCE' property='target.forexRecords.(k1).reference' action='set' />
<assign value='..SubString(source.Records.(k1).VALUEDATE,1,10)' property='target.forexRecords.(k1).valueDate' action='set' />
<assign value='..SubString(source.Records.(k1).MATURITYDATE,1,10)' property='target.forexRecords.(k1).maturityDate' action='set' />
<assign value='source.Records.(k1).UTICCI' property='target.forexRecords.(k1).utiCci' action='set' />
<assign value='source.Records.(k1).PARENTTRADECCE' property='target.forexRecords.(k1).parentTradeCce' action='set' />
<assign value='0' property='target.forexRecords.(k1).matchStatus' action='set' />
<assign value='0' property='target.forexRecords.(k1).archived' action='set' />

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EVAT")' >
<true>
<assign value='"V"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"MEP TERME"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountPaid' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountReceived' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EAAT")' >
<true>
<assign value='"A"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"MEP TERME"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountPaid' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EVSP")' >
<true>
<assign value='"V"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"MEP SPOT"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountPaid' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountReceived' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EVSPA")' >
<true>
<assign value='"V"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"MEP SPOT ANN"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountPaid' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountReceived' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EASP")' >
<true>
<assign value='"A"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"MEP SPOT"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountPaid' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EASPA")' >
<true>
<assign value='"A"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"MEP SPOT ANN"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountPaid' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ERVT")' >
<true>
<assign value='"V"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"PRORO"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountPaid' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountReceived' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ERAT")' >
<true>
<assign value='"A"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"PRORO"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountPaid' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ELAT")' >
<true>
<assign value='"V"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"LEVEE"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountPaid' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ELATA")' >
<true>
<assign value='"V"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"LEVEE ANN"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountPaid' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ELVT")' >
<true>
<assign value='"A"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"LEVEE"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountPaid' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountReceived' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ELVTA")' >
<true>
<assign value='"A"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"LEVEE ANN"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountPaid' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountReceived' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"SWAA")' >
<true>
<assign value='"A"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"SWAP"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountPaid' action='set' />
</true>
</if>

<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"SWAV")' >
<true>
<assign value='"V"' property='target.forexRecords.(k1).sens' action='set' />
<assign value='"SWAP"' property='target.forexRecords.(k1).confType' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.forexRecords.(k1).devisePaid' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.forexRecords.(k1).deviseReceived' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.forexRecords.(k1).amountPaid' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.forexRecords.(k1).amountReceived' action='set' />
</true>
</if>

<if condition='..Contains(target.forexRecords.(k1).amountReceived,",")' >
<true>
<assign value='..Piece(target.forexRecords.(k1).amountReceived,",",1)' property='target.forexRecords.(k1).amountReceived' action='set' />
</true>
<false>
<assign value='target.forexRecords.(k1).amountReceived' property='target.forexRecords.(k1).amountReceived' action='set' />
</false>
</if>
<if condition='..Contains(target.forexRecords.(k1).amountPaid,",")' >
<true>
<assign value='..Piece(target.forexRecords.(k1).amountPaid,",",1)' property='target.forexRecords.(k1).amountPaid' action='set' />
</true>
<false>
<assign value='target.forexRecords.(k1).amountPaid' property='target.forexRecords.(k1).amountPaid' action='set' />
</false>
</if>
<assign value='..replace(target.forexRecords.(k1).amountReceived," ","")' property='target.forexRecords.(k1).amountReceived' action='set' />
<assign value='..replace(target.forexRecords.(k1).amountPaid," ","")' property='target.forexRecords.(k1).amountPaid' action='set' />
</foreach>
</transform>
}

}
