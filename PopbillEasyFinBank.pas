unit PopbillEasyFinBank;

interface

uses
  TypInfo,SysUtils,Classes,Popbill,Linkhub;
type
        TEasyFinBankChargeInfo = class
        public
                unitCost        : string;
                chargeMethod    : string;
                rateSystem      : string;
        end;
        
        TEasyFinBankFlatRate = class
        public
                referenceID     : string;
                contractDt      : string;
                baseDate        : Integer;
                useEndDate      : string;
                state           : Integer;
                closeRequestYN  : boolean;
                useRestrictYN   : boolean;
                closeOnExpired  : boolean;
                unPaidYN        : boolean;
        end;

        TEasyFinBankAccountInfo = class
        public
                accountNumber           : String;
                bankCode       : String;
                accountName   : String;
                accountType     : String;
                state       : Integer;
                regDT     : String;
                memo      : String;
                
                contractDt      : string;
                baseDate        : Integer;
                useEndDate      : string;
                contractState   : Integer;
                closeRequestYN  : boolean;
                useRestrictYN   : boolean;
                closeOnExpired  : boolean;
                unPaidYN        : boolean;
        end;

        TEasyFinBankAccountForm = Record
                BankCode : string;
                AccountNumber : string;
                AccountPWD : string;
                AccountType : string;
                IdentityNumber : string;
                AccountName : string;
                BankID : string;
                FastID : string;
                FastPWD : string;
                Memo : string;
        end;

        TEasyFinBankAccountInfoList = Array Of TEasyFinBankAccountInfo;

        TEasyFinBankJobInfo = class
        public
                jobID           : String;
                jobState        : Integer;
                startDate     : String;
                endDate     : String;
                errorCode       : Integer;
                errorReason     : String;
                jobStartDT      : String;
                jobEndDT        : String;
                regDT           : String;

        end;

        TEasyFinBankJobInfoList = Array Of TEasyFinBankJobInfo;

        TEasyFinBankSearchDetail = class
        public
                tid : string;
                trdate : String;
                trserial  : Integer;
                trdt : string;
                accIn : string;
                accOut : string;
                balance : string;
                remark1 : string;
                remark2 : string;
                remark3 : string;
                remark4 : string;
                regDT   : string;
                memo    : string;
        end;

        TEasyFinBankSearchDetailList = Array Of TEasyFinBankSearchDetail;

        TEasyFinBankSearchResult = class
        public
                code            : Integer;
                total           : Integer;
                perPage         : Integer;
                pageNum         : Integer;
                pageCount       : Integer;
                message         : String;
                lastScrapDT     : String;
                list            : TEasyFinBankSearchDetailList;
        end;

        TEasyFinBankSummary = class
        public
                count : Integer;
                cntAccIn : Integer;
                cntAccOut : Integer;
                totalAccIn : Integer;
                totalAccOut : Integer;                
        end;         
                        

        TEasyFinBankService = class(TPopbillBaseService)
        private
                function jsonToTEasyFinBankAccountInfo(json : String) : TEasyFinBankAccountInfo;
                function jsonToTEasyFinBankJobInfo(json : String) : TEasyFinBankJobInfo;                
        public
                constructor Create(LinkID : String; SecretKey : String);

                // 과금정보 확인
                function GetChargeInfo (CorpNum : String) : TEasyFinBankChargeInfo; overload;

                // 과금정보 확인
                function GetChargeInfo (CorpNum : String; UserID: String) : TEasyFinBankChargeInfo; overload;

                // 정액제 서비스 신청 URL
                function GetFlatRatePopUpURL (CorpNum : String; UserID : String = '') : string;

                // 정액제 서비스 상태 확인
                function GetFlatRateState (CorpNum : string; BankCode : String; AccountNumber : String; UserID: String = '' ) : TEasyFinBankFlatRate; 

                // 계좌 관리 팝업 URL
                function GetBankAccountMgtURL (CorpNum : String; UserID : String = '') : string;

                // 계좌 목록 확인
                function ListBankAccount (CorpNum : string; UserID : string = '') : TEasyFinBankAccountInfoList;

                // 수집 요청 
                function RequestJob (CorpNum : string; BankCode : String; AccountNumber : String; SDate : String; EDate : String; UserID : String = '') : string;

                // 수집 상태 확인
                function GetJobState ( CorpNum : string; jobID : string; UserID: string = '') : TEasyFinBankJobInfo;

                // 수집 상태 목록 확인
                function ListActiveJob (CorpNum : string; UserID:string = '') : TEasyFinBankJobInfoList;

                // 거래 내역 조회
                function Search (CorpNum : string; jobID : string; TradeType : Array Of String; SearchString : String; Page : Integer; PerPage : Integer; Order: String; UserID: string='') : TEasyFinBankSearchResult;

                // 거래 내역 요약정보 조회
                function Summary (CorpNum:string; jobID:string; TradeType : Array Of String; SearchString : String; UserID: string='') : TEasyFinBankSummary;

                // 거래내역 메모 저장
                function SaveMemo(CorpNum:string; TID:String; Memo:string; UserID: string = '') : TResponse;

                // 계좌등록
                function RegistBankAccount(CorpNum : String; BankInfo : TEasyFinBankAccountForm; UsePeriod: String; UserID : String = '') : TResponse; 

                // 계좌수정
                function UpdateBankAccount(CorpNum : String; BankInfo : TEasyFinBankAccountForm; UserID : String = '') : TResponse;

                // 계좌정보 조회
                function GetBankAccountInfo(CorpNum : String; BankCode:String; AccountNumber:String; UserID : String = '') : TEasyFinBankAccountInfo;

                // 정액제 해지신청
                function CloseBankAccountInfo(CorpNum : String; BankCode:String; AccountNumber:String; CloseType:String; UserID : String = '') : TResponse;

                // 정액제 해지신청 취소
                function RevokeCloseBankAccountInfo(CorpNum : String; BankCode:String; AccountNumber:String; UserID : String = '') : TResponse;

        end;
implementation

constructor TEasyFinBankService.Create(LinkID : String; SecretKey : String);
begin
       inherited Create(LinkID,SecretKey);
       AddScope('180');
end;

function UrlEncodeUTF8(stInput : widestring) : string;
  const
    hex : array[0..255] of string = (
     '%00', '%01', '%02', '%03', '%04', '%05', '%06', '%07',
     '%08', '%09', '%0a', '%0b', '%0c', '%0d', '%0e', '%0f',
     '%10', '%11', '%12', '%13', '%14', '%15', '%16', '%17',
     '%18', '%19', '%1a', '%1b', '%1c', '%1d', '%1e', '%1f',
     '%20', '%21', '%22', '%23', '%24', '%25', '%26', '%27',
     '%28', '%29', '%2a', '%2b', '%2c', '%2d', '%2e', '%2f',
     '%30', '%31', '%32', '%33', '%34', '%35', '%36', '%37',
     '%38', '%39', '%3a', '%3b', '%3c', '%3d', '%3e', '%3f',
     '%40', '%41', '%42', '%43', '%44', '%45', '%46', '%47',
     '%48', '%49', '%4a', '%4b', '%4c', '%4d', '%4e', '%4f',
     '%50', '%51', '%52', '%53', '%54', '%55', '%56', '%57',
     '%58', '%59', '%5a', '%5b', '%5c', '%5d', '%5e', '%5f',
     '%60', '%61', '%62', '%63', '%64', '%65', '%66', '%67',
     '%68', '%69', '%6a', '%6b', '%6c', '%6d', '%6e', '%6f',
     '%70', '%71', '%72', '%73', '%74', '%75', '%76', '%77',
     '%78', '%79', '%7a', '%7b', '%7c', '%7d', '%7e', '%7f',
     '%80', '%81', '%82', '%83', '%84', '%85', '%86', '%87',
     '%88', '%89', '%8a', '%8b', '%8c', '%8d', '%8e', '%8f',
     '%90', '%91', '%92', '%93', '%94', '%95', '%96', '%97',
     '%98', '%99', '%9a', '%9b', '%9c', '%9d', '%9e', '%9f',
     '%a0', '%a1', '%a2', '%a3', '%a4', '%a5', '%a6', '%a7',
     '%a8', '%a9', '%aa', '%ab', '%ac', '%ad', '%ae', '%af',
     '%b0', '%b1', '%b2', '%b3', '%b4', '%b5', '%b6', '%b7',
     '%b8', '%b9', '%ba', '%bb', '%bc', '%bd', '%be', '%bf',
     '%c0', '%c1', '%c2', '%c3', '%c4', '%c5', '%c6', '%c7',
     '%c8', '%c9', '%ca', '%cb', '%cc', '%cd', '%ce', '%cf',
     '%d0', '%d1', '%d2', '%d3', '%d4', '%d5', '%d6', '%d7',
     '%d8', '%d9', '%da', '%db', '%dc', '%dd', '%de', '%df',
     '%e0', '%e1', '%e2', '%e3', '%e4', '%e5', '%e6', '%e7',
     '%e8', '%e9', '%ea', '%eb', '%ec', '%ed', '%ee', '%ef',
     '%f0', '%f1', '%f2', '%f3', '%f4', '%f5', '%f6', '%f7',
     '%f8', '%f9', '%fa', '%fb', '%fc', '%fd', '%fe', '%ff');
 var
   iLen,iIndex : integer;
   stEncoded : string;
   ch : widechar;
 begin
   iLen := Length(stInput);
   stEncoded := '';
   for iIndex := 1 to iLen do
   begin
     ch := stInput[iIndex];
     if (ch >= 'A') and (ch <= 'Z') then
       stEncoded := stEncoded + ch
     else if (ch >= 'a') and (ch <= 'z') then
       stEncoded := stEncoded + ch
     else if (ch >= '0') and (ch <= '9') then
       stEncoded := stEncoded + ch
     else if (ch = ' ') then
       stEncoded := stEncoded + '+'
     else if ((ch = '-') or (ch = '_') or (ch = '.') or (ch = '!') or (ch = '*')
       or (ch = '~') or (ch = '\')  or (ch = '(') or (ch = ')')) then
       stEncoded := stEncoded + ch
     else if (Ord(ch) <= $07F) then
       stEncoded := stEncoded + hex[Ord(ch)]
     else if (Ord(ch) <= $7FF) then
     begin
        stEncoded := stEncoded + hex[$c0 or (Ord(ch) shr 6)];
        stEncoded := stEncoded + hex[$80 or (Ord(ch) and $3F)];
     end
     else
     begin
        stEncoded := stEncoded + hex[$e0 or (Ord(ch) shr 12)];
        stEncoded := stEncoded + hex[$80 or ((Ord(ch) shr 6) and ($3F))];
        stEncoded := stEncoded + hex[$80 or ((Ord(ch)) and ($3F))];
     end;
   end;
   result := (stEncoded);
 end;

 

function TEasyFinBankService.RevokeCloseBankAccountInfo(CorpNum : String; BankCode:String; AccountNumber:String; UserID : String = '') : TResponse;
var
        responseJson : string;
        uri : string;
begin
        try
                uri := '/EasyFin/Bank/BankAccount/RevokeClose?BankCode='+BankCode+'&&AccountNumber='+AccountNumber;

                responseJson := httppost(uri, CorpNum, UserID, '');

                if LastErrCode <> 0 then
                begin
                        result.code := LastErrCode;
                        result.message := LastErrMessage;
                end
                else
                begin
                        result.code := getJSonInteger(responseJson,'code');
                        result.message := getJSonString(responseJson,'message');
                end;
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.Message);
                        end
                        else
                        begin
                                result.code := le.code;
                                result.Message := le.Message;
                        end;
                end;
        end;
end;


function TEasyFinBankService.CloseBankAccountInfo(CorpNum : String; BankCode:String; AccountNumber:String; CloseType:String; UserID : String = '') : TResponse;
var
        responseJson : string;
        uri : string;
begin
        try
                uri := '/EasyFin/Bank/BankAccount/Close?BankCode='+BankCode+'&&AccountNumber='+AccountNumber+'&&CloseType='+UrlEncodeUTF8(CloseType);

                responseJson := httppost(uri, CorpNum, UserID, '');

                if LastErrCode <> 0 then
                begin
                        result.code := LastErrCode;
                        result.message := LastErrMessage;
                end
                else
                begin
                        result.code := getJSonInteger(responseJson,'code');
                        result.message := getJSonString(responseJson,'message');
                end;
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.Message);
                        end
                        else
                        begin
                                result.code := le.code;
                                result.Message := le.Message;
                        end;
                end;
        end;
end;

function TEasyFinBankService.RegistBankAccount(CorpNum : String; BankInfo : TEasyFinBankAccountForm; UsePeriod: String; UserID : String = '') : TResponse;
var
        requestJson : string;
        responseJson : string;
        uri : string;
begin
        try
                requestJson := '{';
                requestJson := requestJson + '"BankCode":"'+EscapeString(BankInfo.BankCode)+'",';
                requestJson := requestJson + '"AccountPWD":"'+EscapeString(BankInfo.AccountPWD)+'",';
                requestJson := requestJson + '"AccountType":"'+EscapeString(BankInfo.AccountType)+'",';
                requestJson := requestJson + '"IdentityNumber":"'+EscapeString(BankInfo.IdentityNumber)+'",';
                requestJson := requestJson + '"AccountName":"'+EscapeString(BankInfo.AccountName)+'",';
                requestJson := requestJson + '"BankID":"'+EscapeString(BankInfo.BankID)+'",';
                requestJson := requestJson + '"FastID":"'+EscapeString(BankInfo.FastID)+'",';
                requestJson := requestJson + '"FastPWD":"'+EscapeString(BankInfo.FastPWD)+'",';
                requestJson := requestJson + '"Memo":"'+EscapeString(BankInfo.Memo)+'",';
                requestJson := requestJson + '"AccountNumber":"'+EscapeString(BankInfo.AccountNumber)+'"';
                requestJson := requestJson + '}';

                uri := '/EasyFin/Bank/BankAccount/Regist';

                if UsePeriod <> '' then
                begin
                        uri := uri + '?UsePeriod='+UsePeriod;
                end;

                responseJson := httppost(uri, CorpNum, UserID, requestJson);

                if LastErrCode <> 0 then
                begin
                        result.code := LastErrCode;
                        result.message := LastErrMessage;
                end
                else
                begin
                        result.code := getJSonInteger(responseJson,'code');
                        result.message := getJSonString(responseJson,'message');
                end;
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.Message);
                        end
                        else
                        begin
                                result.code := le.code;
                                result.Message := le.Message;
                        end;
                end;
        end;
end;

function TEasyFinBankService.UpdateBankAccount(CorpNum : String; BankInfo : TEasyFinBankAccountForm; UserID : String = '') : TResponse;
var
        requestJson : string;
        responseJson : string;
        uri : string;
begin
        try
                requestJson := '{';
                requestJson := requestJson + '"AccountPWD":"'+EscapeString(BankInfo.AccountPWD)+'",';
                requestJson := requestJson + '"AccountName":"'+EscapeString(BankInfo.AccountName)+'",';
                requestJson := requestJson + '"BankID":"'+EscapeString(BankInfo.BankID)+'",';
                requestJson := requestJson + '"FastID":"'+EscapeString(BankInfo.FastID)+'",';
                requestJson := requestJson + '"FastPWD":"'+EscapeString(BankInfo.FastPWD)+'",';
                requestJson := requestJson + '"Memo":"'+EscapeString(BankInfo.Memo)+'"';
                requestJson := requestJson + '}';

                uri := '/EasyFin/Bank/BankAccount/'+BankInfo.BankCode+'/'+BankInfo.AccountNumber+'/Update';

                responseJson := httppost(uri, CorpNum, UserID, requestJson);

                if LastErrCode <> 0 then
                begin
                        result.code := LastErrCode;
                        result.message := LastErrMessage;
                end
                else
                begin
                        result.code := getJSonInteger(responseJson,'code');
                        result.message := getJSonString(responseJson,'message');
                end;
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.Message);
                        end
                        else
                        begin
                                result.code := le.code;
                                result.Message := le.Message;
                        end;
                end;
        end;
end;

function TEasyFinBankService.GetChargeInfo (CorpNum : string) : TEasyFinBankChargeInfo;

begin
        Result := GetChargeInfo(CorpNum, '');
end;


function TEasyFinBankService.GetChargeInfo (CorpNum : string; UserID:string) : TEasyFinBankChargeInfo;
var
        responseJson : String;
begin

        try
                responseJson := httpget('/EasyFin/Bank/ChargeInfo',CorpNum,UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.message);
                                exit;
                        end;
                end;
        end;

        if LastErrCode <> 0 then
        begin
                result := TEasyFinBankChargeInfo.Create();
                exit;
        end
        else
        begin        
                try
                        result := TEasyFinBankChargeInfo.Create;
                        result.unitCost := getJSonString(responseJson, 'unitCost');
                        result.chargeMethod := getJSonString(responseJson, 'chargeMethod');
                        result.rateSystem := getJSonString(responseJson, 'rateSystem');
                except
                        on E:Exception do begin
                                if FIsThrowException then
                                begin
                                        raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
                                        exit;
                                end
                                else
                                begin
                                        result := TEasyFinBankChargeInfo.Create();
                                        setLastErrCode(-99999999);
                                        setLastErrMessage('결과처리 실패.[Malformed Json]');
                                        exit;
                                end;
                        end;
                end;
        end;
end;


function TEasyFinBankService.GetFlatRatePopUpURL(CorpNum: string; UserID : String = '') : string;
var
        responseJson : String;
begin

        try
                responseJson := httpget('/EasyFin/Bank?TG=CHRG', CorpNum, UserID);
                result := getJSonString(responseJson,'url');
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code, le.message);
                                exit;
                        end;
                end;
        end;
end;

function TEasyFinBankService.GetFlatRateState (CorpNum : string; BankCode : string; AccountNumber : string; UserID: string) : TEasyFinBankFlatRate;
var
        responseJson : String;
begin
        try
                responseJson := httpget('/EasyFin/Bank/Contract/'+BankCode+'/'+AccountNumber,CorpNum, UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.message);
                                exit;
                        end;
                end;                
        end;
        
        if LastErrCode <> 0 then
        begin
                result := TEasyFinBankFlatRate.Create;
                exit;
        end
        else
        begin
                try
                        result := TEasyFinBankFlatRate.Create;
                        result.referenceID := getJSonString(responseJson, 'referenceID');
                        result.contractDT := getJSonString(responseJson, 'contractDT');
                        result.baseDate := getJsonInteger(responseJson, 'baseDate');
                        result.useEndDate := getJSonString(responseJson, 'useEndDate');
                        result.state := getJsonInteger(responseJson, 'state');
                        result.closeRequestYN := getJsonBoolean(responseJson, 'closeRequestYN');
                        result.useRestrictYN := getJsonBoolean(responseJson, 'useRestrictYN');
                        result.closeOnExpired := getJsonBoolean(responseJson, 'closeOnExpired');
                        result.unPaidYN := getJsonBoolean(responseJson, 'unPaidYN');
                except
                        on E:Exception do begin
                                if FIsThrowException then
                                begin
                                        raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
                                        exit;
                                end
                                else
                                begin
                                        result := TEasyFinBankFlatRate.Create;
                                        setLastErrCode(-99999999);
                                        setLastErrMessage('결과처리 실패.[Malformed Json]');
                                end;
                        end;
                end;
        end;

end;


function TEasyFinBankService.GetBankAccountMgtURL(CorpNum: string; UserID : String = '') : string;
var
        responseJson : String;
begin

        try
                responseJson := httpget('/EasyFin/Bank?TG=BankAccount', CorpNum, UserID);
                result := getJSonString(responseJson,'url');
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code, le.message);
                                exit;
                        end;
                end;
        end;
end;

function TEasyFinBankService.jsonToTEasyFinBankAccountInfo(json : String) : TEasyFinBankAccountInfo;
begin
        result := TEasyFinBankAccountInfo.Create;

        result.accountNumber := getJsonString(json, 'accountNumber');
        result.state := getJsonInteger(json, 'state');
        result.bankCode := getJsonString(json, 'bankCode');
        result.accountName := getJsonString(json, 'accountName');
        result.accountType := getJsonString(json, 'accountType');
        result.regDT := getJsonString(json, 'regDT');
        result.memo := getJsonString(json, 'memo');
        result.contractDT := getJsonString(json, 'contractDT');
        result.baseDate := getJsonInteger(json, 'baseDate');
        result.useEndDate := getJsonString(json, 'useEndDate');
        result.contractState := getJsonInteger(json, 'contractState');
        
        result.closeRequestYN := getJsonBoolean(json, 'closeRequestYN');
        result.useRestrictYN := getJsonBoolean(json, 'useRestrictYN');
        result.closeOnExpired := getJsonBoolean(json, 'closeOnExpired');
        result.unPaidYN := getJsonBoolean(json, 'unPaidYN');

end;



function TEasyFinBankService.GetBankAccountInfo(CorpNum : String; BankCode:String; AccountNumber:String; UserID : String = '') : TEasyFinBankAccountInfo;
var
        responseJson : string;
begin

        responseJson := httpget('/EasyFin/Bank/BankAccount/'+BankCode+'/'+AccountNumber, CorpNum, UserID);

        result :=  jsonToTEasyFinBankAccountInfo(responseJson);

end;


function TEasyFinBankService.ListBankAccount (CorpNum : string; UserID:string) : TEasyFinBankAccountInfoList;
var
        responseJson : string;
        jSons : ArrayOfString;
        i : Integer;
begin

        try
                responseJson := httpget('/EasyFin/Bank/ListBankAccount', CorpNum, UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.message);
                                exit;
                        end
                        else
                        begin
                                setLength(result,0);
                                exit;
                        end;
                end;
        end;

        if responseJson = '[]' then
        begin
                if FIsThrowException then
                begin
                        raise EPopbillException.Create(-99999999, '등록된 계좌 정보가 존재하지 않습니다.');
                        exit;
                end
                else
                begin
                        setLength(result,0);
                        setLastErrCode(-99999999);
                        setLastErrMessage('등록된 계좌 정보가 존재하지 않습니다.');
                        exit;
                end;
        end;

        if LastErrCode <> 0 then
        begin
                exit;
        end
        else
        begin
                try
                        jSons := ParseJsonList(responseJson);
                        SetLength(result,Length(jSons));

                        for i:= 0 to Length(jSons) -1 do
                        begin
                                result[i] := jsonToTEasyFinBankAccountInfo(jSons[i]);
                        end;
                except
                        on E:Exception do begin
                                if FIsThrowException then
                                begin
                                        raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
                                        exit;
                                end
                                else
                                begin
                                        setLength(result,0);
                                        setLastErrCode(-99999999);
                                        setLastErrMessage('결과처리 실패.[Malformed Json]');
                                        exit;
                                end;
                        end;
                end;
        end;
end;

function TEasyFinBankService.RequestJob (CorpNum : string; BankCode : String; AccountNumber : String; SDate: String; EDate: String; UserID: String = '') : string;
var
        responseJson : string;

begin
        try        
                responseJson := httppost('/EasyFin/Bank/BankAccount?BankCode='+BankCode+'&&AccountNumber='+AccountNumber+'&&SDate='+SDate+'&&EDate='+EDate, CorpNum, UserID, '', '');
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code, le.message);
                                exit;
                        end
                        else
                        begin
                                result := '';
                                exit;
                        end;
                end;
        end;

        if LastErrCode <> 0 then
        begin
                result := '';
                exit;
        end
        else
        begin
                result := getJsonString(responseJson, 'jobID');
                exit;
        end;
end;

function TEasyFinBankService.jsonToTEasyFinBankJobInfo(json : String) : TEasyFinBankJobInfo;
begin
        result := TEasyFinBankJobInfo.Create;

        result.jobID := getJsonString(json, 'jobID');
        result.jobState := getJsonInteger(json, 'jobState');
        result.startDate := getJsonString(json, 'startDate');
        result.endDate := getJsonString(json, 'endDate');
        result.errorCode := getJsonInteger(json, 'errorCode');
        result.errorReason := getJsonString(json, 'errorReason');
        result.jobStartDT := getJsonString(json, 'jobStartDT');
        result.jobEndDT := getJsonString(json, 'jobEndDT');
        result.regDT := getJsonString(json, 'regDT');
end;


function TEasyFinBankService.GetJobState ( CorpNum : string; jobID : string; UserID :string = '') : TEasyFinBankJobInfo;
var
        responseJson : string;

begin
        if Not ( length ( jobID ) = 18 ) then
        begin
                if FIsThrowException then
                begin
                        raise EPopbillException.Create(-99999999, '작업아이디(jobID)가 올바르지 않습니다.');
                        Exit;
                end
                else
                begin
                        result := TEasyFinBankJobInfo.Create;
                        setLastErrCode(-99999999);
                        setLastErrMessage('작업아이디(jobID)가 올바르지 않습니다.');
                        exit;
                end;
        end;

        try
                responseJson := httpget('/EasyFin/Bank/'+ jobID + '/State', CorpNum, UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.message);
                                exit;
                        end;
                end;
        end;

        if LastErrCode <> 0 then
        begin
                result := TEasyFinBankJobInfo.Create;
                exit;
        end
        else
        begin
                result := jsonToTEasyFinBankJobInfo ( responseJson ) ;
        end;
end;

function TEasyFinBankService.ListActiveJob (CorpNum : string; UserID:string) : TEasyFinBankJobInfoList;
var
        responseJson : string;
        jSons : ArrayOfString;
        i : Integer;
begin

        try
                responseJson := httpget('/EasyFin/Bank/JobList', CorpNum, UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.message);
                                exit;
                        end
                        else
                        begin
                                setLength(result,0);
                                exit;
                        end;
                end;
        end;

        if responseJson = '[]' then
        begin
                if FIsThrowException then
                begin
                        raise EPopbillException.Create(-99999999, '작업 요청건이 존재하지 않습니다.');
                        exit;
                end
                else
                begin
                        setLength(result,0);
                        setLastErrCode(-99999999);
                        setLastErrMessage('작업 요청건이 존재하지 않습니다.');
                        exit;
                end;
        end;

        if LastErrCode <> 0 then
        begin
                exit;
        end
        else
        begin
                try
                        jSons := ParseJsonList(responseJson);
                        SetLength(result,Length(jSons));

                        for i:= 0 to Length(jSons) -1 do
                        begin
                                result[i] := jsonToTEasyFinBankJobInfo(jSons[i]);
                        end;
                except
                        on E:Exception do begin
                                if FIsThrowException then
                                begin
                                        raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
                                        exit;
                                end
                                else
                                begin
                                        setLength(result,0);
                                        setLastErrCode(-99999999);
                                        setLastErrMessage('결과처리 실패.[Malformed Json]');
                                        exit;
                                end;
                        end;
                end;
        end;
end;



 
function TEasyFinBankService.Search (CorpNum:string; jobID:string; TradeType : Array Of String; SearchString : String; Page: Integer; PerPage : Integer; Order: String; UserID: string='') : TEasyFinBankSearchResult;
var
        responseJson : string;
        uri : String;
        tradeTypeList : String;
        i : integer;
        jSons : ArrayOfString;
begin
        if Not ( length ( jobID ) = 18 ) then
        begin
                if FIsThrowException then
                begin
                        raise EPopbillException.Create(-99999999, '작업아이디(jobID)가 올바르지 않습니다.');
                        Exit;
                end
                else
                begin
                        result := TEasyFinBankSearchResult.Create;
                        result.code := -99999999;
                        result.message := '작업아이디(jobID)가 올바르지 않습니다.';
                        exit;
                end;

        end;

        for i := 0 to High ( TradeType ) do
        begin
                if TradeType[i] <> '' Then
                tradeTypeList := tradeTypeList + TradeType[i];

                if i <> High(TradeType) then
                tradeTypeList := tradeTypeList + ',';
        end;

                                          
        if Page < 1 then page := 1;
        if PerPage < 1 then PerPage := 500;

        uri := '/EasyFin/Bank/'+jobID;
        uri := uri + '?TradeType=' + tradeTypeList;

        if SearchString <> '' then
        begin
                uri := uri + '&&SearchString='+ UrlEncodeUTF8(SearchString);
        end;
        
        uri := uri + '&&Page=' + IntToStr(Page) + '&&PerPage='+ IntToStr(PerPage);
        uri := uri + '&&Order=' + order;

        try
                responseJson := httpget(uri, CorpNum, UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code, le.message);
                                exit;
                        end
                        else
                        begin
                                result := TEasyFinBankSearchResult.Create;
                                result.code := le.code;
                                result.message := le.message;
                                exit;
                        end;
                end;
        end;

        if LastErrCode <> 0 then
        begin
                result := TEasyFinBankSearchResult.Create;
                result.code := LastErrCode;
                result.message := LastErrMessage;
                exit;
        end
        else
        begin
        
                result := TEasyFinBankSearchResult.Create;

                result.code := getJSonInteger(responseJson, 'code');
                result.total := getJSonInteger(responseJson, 'total');
                result.perPage := getJSonInteger(responseJson, 'perPage');
                result.pageNum := getJSonInteger(responseJson, 'pageNum');
                result.pageCount := getJSonInteger(responseJson, 'pageCount');
                result.message := getJSonString(responseJson, 'message');
                result.lastScrapDT := getJSonString(responseJson, 'lastScrapDT');

                try
                        jSons := getJsonList(responseJson, 'list');
                        SetLength(result.list, Length(jSons));
                        for i:=0 to Length(jSons)-1 do
                        begin
                                result.list[i] := TEasyFinBankSearchDetail.Create;
                                result.list[i].tid := getJsonString (jSons[i], 'tid');
                                result.list[i].trdt := getJsonString (jSons[i], 'trdt');
                                result.list[i].trdate := getJsonString (jSons[i], 'trdate');
                                result.list[i].trserial := getJsonInteger (jSons[i], 'trserial');
                                result.list[i].accIn := getJsonString (jSons[i], 'accIn');
                                result.list[i].accOut := getJsonString (jSons[i], 'accOut');
                                result.list[i].balance := getJsonString (jSons[i], 'balance');
                                result.list[i].remark1 := getJsonString (jSons[i], 'remark1');
                                result.list[i].remark2 := getJsonString (jSons[i], 'remark2');
                                result.list[i].remark3 := getJsonString (jSons[i], 'remark3');
                                result.list[i].remark4 := getJsonString (jSons[i], 'remark4');
                                result.list[i].regDT := getJsonString (jSons[i], 'regDT');
                                result.list[i].memo := getJsonString (jSons[i], 'memo');
                        end;

                except
                        on E:Exception do begin
                                if FIsThrowException then
                                begin
                                        raise EPopbillException.Create(-99999999,'결과처리 실패.[Malformed Json]');
                                        exit;
                                end
                                else
                                begin
                                        result := TEasyFinBankSearchResult.Create;
                                        result.code := -99999999;
                                        result.message := '결과처리 실패.[Malformed Json]';
                                        exit;
                                end;

                        end;
                end;
        end;
end;


function TEasyFinBankService.Summary (CorpNum:string; jobID:string; TradeType : Array Of String; SearchString : String; UserID: string='') : TEasyFinBankSummary;
var
        responseJson : string;
        uri : String;
        tradeTypeList : String;
        i : integer;
begin
        if Not ( length ( jobID ) = 18 ) then
        begin
                if FIsThrowException then
                begin
                        raise EPopbillException.Create(-99999999, '작업아이디(jobID)가 올바르지 않습니다.');
                        Exit;
                end
                else
                begin
                        result := TEasyFinBankSummary.Create;
                        setLastErrCode(-99999999);
                        setLastErrMessage('작업아이디(jobID)가 올바르지 않습니다.');
                        exit;
                end;

        end;
        
        for i := 0 to High ( TradeType ) do
        begin
                if TradeType[i] <> '' Then
                tradeTypeList := tradeTypeList + TradeType[i];

                if i <> High(TradeType) then
                tradeTypeList := tradeTypeList + ',';
        end;

        uri := '/EasyFin/Bank/'+jobID+'/Summary';
        uri := uri + '?TradeType=' + tradeTypeList;

        if SearchString <> '' then
        begin
                uri := uri + '&&SearchString='+ UrlEncodeUTF8(SearchString);
        end;

        try
                responseJson := httpget(uri, CorpNum, UserID);
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.message);
                                exit;
                        end;
                end;                
        end;

        if LastErrCode <> 0 then
        begin
                result := TEasyFinBankSummary.Create;
                exit;
        end
        else
        begin        
                result := TEasyFinBankSummary.Create;
                result.count := GetJSonInteger(responseJson, 'count');
                result.cntAccIn := GetJSonInteger(responseJson, 'cntAccIn');
                result.cntAccOut := GetJSonInteger(responseJson, 'cntAccOut');
                result.totalAccIn := GetJSonInteger(responseJson, 'totalAccIn');
                result.totalAccOut := GetJSonInteger(responseJson, 'totalAccOut');                
        end;
end;

function TEasyFinBankService.SaveMemo(CorpNum:string; TID:String; Memo:string; UserID: string = '') : TResponse;
var
        responseJson : string;
begin
        if Not ( length ( TID ) = 32 ) then
        begin
                if FIsThrowException then
                begin
                        raise EPopbillException.Create(-99999999, '거래내역 아이디가 올바르지 않습니다.');
                        Exit;
                end
                else
                begin
                        setLastErrCode(-99999999);
                        setLastErrMessage('거래내역 아이디가 올바르지 않습니다.');
                        exit;
                end;

        end;

        
        try
                responseJson := httppost('/EasyFin/Bank/SaveMemo?TID='+TID+'&&Memo='+UrlEncodeUTF8(Memo), CorpNum, UserID, '', '');
        except
                on le : EPopbillException do begin
                        if FIsThrowException then
                        begin
                                raise EPopbillException.Create(le.code,le.Message);
                        end;
                        
                        result.code := le.code;
                        result.message := le.Message;
                end;
        end;
        
        if LastErrCode <> 0 then
        begin
                result.code := LastErrCode;
                result.message := LastErrMessage;
                exit;
        end
        else
        begin
                result.code := getJSonInteger(responseJson,'code');
                result.message := getJSonString(responseJson,'message');
        end;

end;
end.
