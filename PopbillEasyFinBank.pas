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

        TEasyFinBankService = class(TPopbillBaseService)
        private

        public
                constructor Create(LinkID : String; SecretKey : String);
        end;

implementation

constructor TEasyFinBankService.Create(LinkID : String; SecretKey : String);
begin
       inherited Create(LinkID,SecretKey);
       AddScope('180');
end;

end.
