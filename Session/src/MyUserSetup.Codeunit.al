namespace PC.Session.UserSetup;

using System.Security.User;
using System.Environment.Configuration;

codeunit 50150 "My User Setup"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;
    SingleInstance = true;

    var
        TempUserSetup: Record "User Setup" temporary;
        Initialized: Boolean;

    procedure Initialize()
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.ReadIsolation := IsolationLevel::ReadUncommitted;
        if UserSetup.Get(UserId()) then
            this.TempUserSetup := UserSetup
        else
            this.Clear();

        this.Initialized := true;
    end;

    procedure Refresh()
    begin
        if not Initialized then
            this.Initialize();
    end;

    procedure Clear()
    begin
        ClearAll();
    end;

    procedure GetValue(): Record "User Setup" temporary
    begin
        this.Refresh();
        exit(this.TempUserSetup);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', true, true)]
    local procedure OnAfterLogin()
    begin
        this.Initialize();
    end;
}
