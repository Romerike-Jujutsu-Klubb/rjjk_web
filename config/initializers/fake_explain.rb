module ActiveRecord::ConnectionAdapters
  class JdbcAdapter < AbstractAdapter
    def explain(query, *binds)
      if query !~ /^\s*(INSERT|UPDATE|DELETE)/i
        logger.warn "Query took a long time: #{query}"
        return
      end
      ActiveRecord::Base.connection.execute("EXPLAIN #{query}", 'EXPLAIN', binds)
    end
  end
end
