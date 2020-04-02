-- migrations/1585784887-filter_rewards_account.sql
-- :up

create or replace function txn_filter_account_activity(acc text, type transaction_type, fields jsonb) returns jsonb as $$
begin
    case
        when type = 'rewards_v1' then
            return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text, gateway text) where account = acc));
        when type = 'payment_v2' then
            if fields#>'{payer}' = acc then
                return fields;
            else
                return jsonb_set(fields, '{payees}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{payees}') as x(payee text, amount bigint) where payee = acc));
            end if;
        else
            return fields;
    end case;
end; $$
language plpgsql;


-- :down

create or replace function txn_filter_account_activity(acc text, type transaction_type, fields jsonb) returns jsonb as $$
begin
    case
        when type = 'rewards_v1' then
            return jsonb_set(fields, '{rewards}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{rewards}') as x(account text, amount bigint, type text) where account = acc));
        when type = 'payment_v2' then
            if fields#>'{payer}' = acc then
                return fields;
            else
                return jsonb_set(fields, '{payees}', (select jsonb_agg(x) from jsonb_to_recordset(fields#>'{payees}') as x(payee text, amount bigint) where payee = acc));
            end if;
        else
            return fields;
    end case;
end; $$
language plpgsql;
