package org.voltdb.chargingdemo.callbacks;

import org.voltdb.VoltTable;
import org.voltdb.chargingdemo.BaseChargingDemo;
import org.voltdb.chargingdemo.UserTransactionState;
import org.voltdb.client.ClientResponse;
import org.voltdb.client.ProcedureCallback;
import org.voltdb.voltutil.stats.SafeHistogramCache;

import chargingdemoprocs.ReferenceData;

public class ReportQuotaUsageCallback implements ProcedureCallback {

    UserTransactionState userTransactionState;
    SafeHistogramCache shc;
    long startMs = System.currentTimeMillis();

    public ReportQuotaUsageCallback(UserTransactionState userTransactionState, SafeHistogramCache shc) {
        this.userTransactionState = userTransactionState;
        this.shc = shc;
    }

    /*
     * (non-Javadoc)
     *
     * @see org.voltdb.chargingdemo.ReportLatencyCallback#clientCallback(org.voltdb.
     * client.ClientResponse)
     */
    @Override
    public void clientCallback(ClientResponse arg0) throws Exception {

        // if the call worked....
        if (arg0.getStatus() == ClientResponse.SUCCESS) {

            shc.reportLatency(BaseChargingDemo.REPORT_QUOTA_USAGE, startMs, BaseChargingDemo.REPORT_QUOTA_USAGE, BaseChargingDemo.HISTOGRAM_SIZE_MS);

            // if we have an expected response...
            if (arg0.getAppStatus() == ReferenceData.STATUS_ALL_UNITS_ALLOCATED
                    || arg0.getAppStatus() == ReferenceData.STATUS_SOME_UNITS_ALLOCATED
                    || arg0.getAppStatus() == ReferenceData.STATUS_NO_MONEY
                    || arg0.getAppStatus() == ReferenceData.STATUS_OK) {

                // Mark transaction as finished so we can start another one
                userTransactionState.endTran();

                // Get balance for user, based on finished transactions.
                VoltTable balanceTable = arg0.getResults()[arg0.getResults().length - 2];

                // Get total value of outstanding reservations
                VoltTable reservationTable = arg0.getResults()[arg0.getResults().length - 1];

                if (balanceTable.advanceRow()) {

                    long balance = balanceTable.getLong("balance");
                    userTransactionState.sessionId = balanceTable.getLong("sessionid");

                    long reserved = 0;

                    if (reservationTable.advanceRow()) {
                        reserved = reservationTable.getLong("allocated_amount");
                        if (reservationTable.wasNull()) {
                            reserved = 0;
                        }
                    }

                    userTransactionState.currentlyReserved = reserved;
                    userTransactionState.spendableBalance = balance - reserved;

                    // We should never see a negative balance...
                    if (userTransactionState.spendableBalance < 0) {
                        BaseChargingDemo.msg("ReportUsageCreditCallback user=" + userTransactionState.id
                                + ": negative balance of " + userTransactionState.spendableBalance + " seen");
                    }

                } else {
                    // We should never detect a nonexistent balance...
                    BaseChargingDemo.msg(
                            "ReportUsageCreditCallback user=" + userTransactionState.id + ": doesn't have a balance");
                }

            } else {
                // We got an app status code we weren't expecting... should never happen..
                BaseChargingDemo.msg(
                        "ReportUsageCreditCallback user=" + userTransactionState.id + ":" + arg0.getAppStatusString());
            }
        } else {
            // We got some form of Volt error code.

            shc.reportLatency(BaseChargingDemo.REPORT_QUOTA_USAGE + "FAIL", startMs,
                    BaseChargingDemo.REPORT_QUOTA_USAGE + "FAIL", BaseChargingDemo.HISTOGRAM_SIZE_MS);

            BaseChargingDemo
                    .msg("ReportUsageCreditCallback user=" + userTransactionState.id + ":" + arg0.getStatusString());
        }
    }

}
