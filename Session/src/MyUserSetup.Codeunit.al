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
        TempUserSetupPerBranchW1ELC: Record "User Setup Per Branch W1 ELC" temporary;
        Initialized: Boolean;

    /// <summary>
    /// Initializes the user setup by reading the current user's settings from the "User Setup" table. This method is called after the user logs in to ensure that the latest settings are available throughout the session. The settings are stored in a temporary record for quick access, and the method ensures that it only initializes once per session. If the user does not have a record in the "User Setup" table, it clears any existing data to avoid using stale information.
    /// </summary>
    procedure Initialize()
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.ReadIsolation := IsolationLevel::ReadUncommitted;
        if UserSetup.Get(UserId()) then begin
            ImplementUserSetup(UserSetup);
            ImplementUserSetupPerBranch();
        end else
            this.Clear();

        this.Initialized := true;
    end;

    /// <summary>
    /// Refreshes the user setup by initializing it. This method can be used for quick access. It checks if the user setup has already been initialized to avoid unnecessary re-initialization, ensuring efficient performance while keeping the user settings up to date throughout the session.
    /// </summary>
    procedure Refresh()
    begin
        if not Initialized then
            this.Initialize();
    end;

    /// <summary>
    /// Clears the temporary user setup record. This method is used to remove any existing data from the temporary record when there is no corresponding record for the current user in the "User Setup" table. It ensures that stale or irrelevant information is not retained in the session, providing a clean state for users who do not have specific settings defined. This method can be called during initialization or when resetting the user setup to maintain data integrity and accuracy.
    /// </summary>
    procedure Clear()
    begin
        ClearAll();
    end;

    /// <summary>
    /// Retrieves the current user's settings from the temporary record. This method first calls the Refresh method to ensure that the user setup is initialized and up to date before returning the temporary record containing the user's settings. It provides a convenient way for other parts of the application to access the current user's configuration without needing to directly query the "User Setup" table, improving performance and encapsulating the logic for managing user settings within this codeunit.
    /// </summary>
    /// <returns>The temporary record containing the current user's settings.</returns>
    procedure GetUserSetup(): Record "User Setup" temporary
    begin
        this.Refresh();
        exit(this.TempUserSetup);
    end;

    /// <summary>
    /// Retrieves the current user's settings for a specific branch from the "User Setup Per Branch W1 ELC" table. This method allows for filtering the user setup based on the provided branch code, enabling users to have different settings for different branches if necessary. It returns a temporary record containing the user settings specific to the given branch, providing flexibility in managing user configurations across multiple branches within the application.
    /// </summary>
    /// <param name="BranchCode">The code of the branch for which to retrieve the user settings.</param>
    /// <returns>A temporary record containing the user settings for the specified branch.</returns>
    procedure GetUserSetupForBranch(BranchCode: Code[20]): Record "User Setup Per Branch W1 ELC" temporary
    var
        TempUserSetupPerBranchCopyW1ELC: Record "User Setup Per Branch W1 ELC" temporary;
    begin
        this.Refresh();
        if TempUserSetupPerBranchW1ELC.Get(UserId(), BranchCode) then
            TempUserSetupPerBranchCopyW1ELC := TempUserSetupPerBranchW1ELC;

        exit(TempUserSetupPerBranchCopyW1ELC);
    end;

    local procedure ImplementUserSetup(var UserSetup: Record "User Setup")
    begin
        this.TempUserSetup := UserSetup;
    end;

    local procedure ImplementUserSetupPerBranch()
    var
        UserSetupPerBranchW1ELC: Record "User Setup Per Branch W1 ELC";
    begin
        UserSetupPerBranchW1ELC.ReadIsolation := IsolationLevel::ReadUncommitted;
        UserSetupPerBranchW1ELC.SetRange("User ID", this.TempUserSetup."User ID");
        if UserSetupPerBranchW1ELC.FindSet() then
            repeat
                this.TempUserSetupPerBranchW1ELC := UserSetupPerBranchW1ELC;
                this.TempUserSetupPerBranchW1ELC.Insert();
            until UserSetupPerBranchW1ELC.Next() = 0;
    end;

    /// <summary>
    /// Event subscriber that triggers the initialization of the user setup after the user logs in. This method is subscribed to the OnAfterLogin event of the System Initialization codeunit, ensuring that it runs immediately after a successful login. By calling the Initialize method, it ensures that the user's settings are loaded and available for use throughout the session, providing a seamless experience where user-specific configurations are applied right from the start.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"System Initialization", OnAfterLogin, '', true, true)]
    local procedure OnAfterLogin()
    begin
        this.Initialize();
    end;
}
