tableextension 50150 "Sales Header" extends "Sales Header"
{
    fields
    {
        field(50150; "User Phone No."; Text[250])
        {
            Caption = 'User Phone No.';
            DataClassification = ToBeClassified;
        }
    }

    trigger OnBeforeInsert()
    var
        MyUserSetup: Codeunit "My User Setup";
    begin
        "User Phone No." := MyUserSetup.GetUserSetup()."Phone No.";
        "Branch W1 ELC" := MyUserSetup.GetUserSetup()."Branch W1 ELC";
    end;
}
