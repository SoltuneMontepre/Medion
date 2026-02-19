namespace Medion.Shared.Enums;

/// <summary>
///     Represents the business status of an audited action.
///     Used for dashboard filtering and monitoring success rates.
/// </summary>
public enum ActionStatus
{
    /// <summary>
    ///     The action completed successfully.
    /// </summary>
    Success = 1,

    /// <summary>
    ///     The action failed due to an error.
    /// </summary>
    Failed = 2,

    /// <summary>
    ///     The action is still in progress or awaiting completion.
    /// </summary>
    Pending = 3
}
