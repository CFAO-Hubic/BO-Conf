Class CFAO.HUBIC.BofficeConf.DtTransform.EnregJrnForexToEAI Extends Ens.DataTransformDTL [ DependsOn = (CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch, CFAO.HUBIC.BofficeConf.Table.JrnForexTab) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='CFAO.HUBIC.BofficeConf.recordMap.JournalForex.Batch' targetClass='CFAO.HUBIC.BofficeConf.Table.JrnForexTab' create='new' language='objectscript' >
<annotation>Enregistrement des données issus du journal Forex pour le flux Bo Conf</annotation>
<foreach property='source.Records()' key='k1' >
<assign value='source.Records.(k1).%Source' property='target.JrnForexRcds.(k1).Filename' action='set' />
<assign value='source.Records.(k1).IDforex' property='target.JrnForexRcds.(k1).IDForex' action='set' />
<assign value='..SubString(source.Records.(k1).TRADEDATE,1,10)' property='target.JrnForexRcds.(k1).TRADEDATE' action='set' />
<assign value='source.Records.(k1).CPTYSHORTNAME' property='target.JrnForexRcds.(k1).CPTYSHORTNAME' action='set' />

<assign value='source.Records.(k1).TRADETYPESHORTNAME' property='target.JrnForexRcds.(k1).TRADETYPESHORTNAME' action='set' />


<assign value='..replace(target.JrnForexRcds.(k1).AMOUNT1," ","")' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='source.Records.(k1).CLIENTRATE' property='target.JrnForexRcds.(k1).CLIENTRATE' action='set' />

<assign value='source.Records.(k1).SPOTRATE' property='target.JrnForexRcds.(k1).SPOTRATE' action='set' />
<assign value='source.Records.(k1).REMAININGAMOUNT1' property='target.JrnForexRcds.(k1).REMAININGAMOUNT1' action='set' />
<assign value='source.Records.(k1).APPLICATIVESTATUSNAME' property='target.JrnForexRcds.(k1).APPLICATIVESTATUSNAME' action='set' />
<assign value='source.Records.(k1).REFERENCE' property='target.JrnForexRcds.(k1).REFERENCE' action='set' />
<assign value='..SubString(source.Records.(k1).VALUEDATE,1,10)' property='target.JrnForexRcds.(k1).VALUEDATE' action='set' />
<assign value='..SubString(source.Records.(k1).MATURITYDATE,1,10)' property='target.JrnForexRcds.(k1).MATURITYDATE' action='set' />
<assign value='source.Records.(k1).UTICCI' property='target.JrnForexRcds.(k1).UTICCI' action='set' />
<assign value='source.Records.(k1).PARENTTRADECCE' property='target.JrnForexRcds.(k1).PARENTTRADECCE' action='set' />
<assign value='"NON"' property='target.JrnForexRcds.(k1).rapprocherOUINON' action='set' />
<assign value='"NON"' property='target.JrnForexRcds.(k1).StatutHistoForex' action='set' />
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EVAT")' >
<true>
<assign value='"V"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"MEP TERME"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EAAT")' >
<true>
<assign value='"A"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"MEP TERME"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EVSP")' >
<true>
<assign value='"V"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"MEP SPOT"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EVSPA")' >
<true>
<assign value='"V"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"MEP SPOT ANN"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EASP")' >
<true>
<assign value='"A"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"MEP SPOT"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"EASPA")' >
<true>
<assign value='"A"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"MEP SPOT ANN"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ERVT")' >
<true>
<assign value='"V"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"PRORO"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ERAT")' >
<true>
<assign value='"A"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"PRORO"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ELAT")' >
<true>
<assign value='"V"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"LEVEE"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ELATA")' >
<true>
<assign value='"V"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"LEVEE ANN"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ELVT")' >
<true>
<assign value='"A"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"LEVEE"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"ELVTA")' >
<true>
<assign value='"A"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"LEVEE ANN"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"SWAA")' >
<true>
<assign value='"A"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"SWAP"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</true>
</if>
<if condition='..StartsWith(source.Records.(k1).TRADETYPESHORTNAME,"SWAV")' >
<true>
<assign value='"V"' property='target.JrnForexRcds.(k1).SensVouA' action='set' />
<assign value='"SWAP"' property='target.JrnForexRcds.(k1).TypeConfirmation' action='set' />
<assign value='source.Records.(k1).CURRENCY1SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY2SHORTNAME' action='set' />
<assign value='source.Records.(k1).CURRENCY2SHORTNAME' property='target.JrnForexRcds.(k1).CURRENCY1SHORTNAME' action='set' />
<assign value='source.Records.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
<assign value='source.Records.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</true>
</if>
<if condition='..Contains(target.JrnForexRcds.(k1).AMOUNT1,",")' >
<true>
<assign value='..Piece(target.JrnForexRcds.(k1).AMOUNT1,",",1)' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</true>
<false>
<assign value='target.JrnForexRcds.(k1).AMOUNT1' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
</false>
</if>
<if condition='..Contains(target.JrnForexRcds.(k1).AMOUNT2,",")' >
<true>
<assign value='..Piece(target.JrnForexRcds.(k1).AMOUNT2,",",1)' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</true>
<false>
<assign value='target.JrnForexRcds.(k1).AMOUNT2' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</false>
</if>
<assign value='..replace(target.JrnForexRcds.(k1).AMOUNT1," ","")' property='target.JrnForexRcds.(k1).AMOUNT1' action='set' />
<assign value='..replace(target.JrnForexRcds.(k1).AMOUNT2," ","")' property='target.JrnForexRcds.(k1).AMOUNT2' action='set' />
</foreach>
</transform>
}

}
