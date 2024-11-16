local PromiseClass = Glu.glass.register({
  class_name = "PromiseClass",
  name = "promise",
  call = "clone",
  setup = function(___, self, opts)
    -- TODO: Consider adding explicit support for Promise.resolve-like behavior
    -- Currently we handle:
    -- 1. Direct value returns (automatically continue chain with value)
    -- 3. New Promise returns (wait for promise resolution)
    -- Future: Add Promise.resolve pattern for explicit immediate resolution

    -- Static methods for Promise
    function self.resolve(value)
      return ___.promise(function(resolve)
        resolve(value)
      end)
    end

    function self.reject(reason)
      return ___.promise(function(_, reject)
        reject(reason)
      end)
    end

    function self.all(promises)
      return ___.promise(function(resolve, reject)
        local results = {}
        local completed = 0
        local total = #promises

        if total == 0 then
          resolve({})
          return
        end

        for i, promise in ipairs(promises) do
          promise:next(function(value)
            results[i] = value
            completed = completed + 1
            if completed == total then
              resolve(results)
            end
          end):catch(function(err)
            reject(err)
          end)
        end
      end)
    end

    function self.clone(executor, parent_promise) -- We don't expose this parameter to developers
      -- print("Starting clone")
      local promise = {
        state = "pending",
        value = nil,
        chain = {},
        current_index = 1,
        chain_id = parent_promise and parent_promise.chain_id or ___.id() -- Use parent's ID or create new one
      }
      -- print("Created promise object with chain_id:", promise.chain_id)

      local function execute_chain(start_index, input_value)

        local function handle_promise_like_result(promise_result, current_promise, current_index)
          -- print(">>> Got promise-like result, checking chain ID")
          if promise_result.chain_id == current_promise.chain_id then
            -- print(">>> Promise is already part of our chain, using directly")
          else
            -- print(">>> New chain detected, creating simple resolver")
          end

          promise_result:next(
            function(resolved_value)
              -- print(">>> Promise resolved with:", resolved_value)
              current_promise.state = "fulfilled"
              execute_chain(current_index + 1, resolved_value)
            end
          )
          return true -- Indicate we handled a promise-like result
        end

        -- print("Executing chain from index:", start_index, "with value:", input_value)
        -- print(">>> Chain structure at start:")
        for i, step in ipairs(promise.chain) do
          -- print(string.format(">>> Step %d: %s", i, step.type))
        end
        local index = start_index
        -- If we have nothing to execute, that's fine!
        if #promise.chain == 0 then
          -- print("Chain empty, nothing to execute")
          return
        end

        while index <= #promise.chain do
          local step = promise.chain[index]
          -- print("Processing step type:", step.type, "at index:", index)

          -- For next handlers
          if step.type == "next" and promise.state == "fulfilled" then
            local success, result = pcall(step.handler, input_value)
            if success then
              if type(result) == "table" and result.next then
                if type(result) == "table" and result.next then
                  return handle_promise_like_result(result, promise, index)
                end
              else
                input_value = result
                index = index + 1
              end
            else
              promise.state = "rejected"
              promise.value = result
              while index <= #promise.chain and promise.chain[index].type ~= "catch" do
                index = index + 1
              end
            end
          -- For catch handlers
          elseif step.type == "catch" and promise.state == "rejected" then
            -- print(">>> Entering catch handler processing")
            local success, result = pcall(step.handler, input_value)
            if success then
              -- print(">>> Catch handler succeeded")
              -- print(">>> Result type:", type(result))
              if result then
                -- print(">>> Result has these keys:", table.concat(table.keys(result) or {}, ", "))
              end
              if type(result) == "table" and result.next then
                -- print(">>> Detected promise-like result")
                return handle_promise_like_result(result, promise, index)
              else
                -- print(">>> Normal value from catch handler, continuing chain")
                promise.state = "fulfilled"
                input_value = result
                index = index + 1
              end
            else
              -- print(">>> Catch handler failed with:", result)
              promise.value = result
              index = index + 1
            end
          elseif step.type == "finally" then
            step.handler()
            index = index + 1
          else
            -- Skip handlers that don't match current state
            index = index + 1
          end
        end
      end

      -- Always return self from handlers so we can chain more
      function promise:next(handler)
        -- print("Adding next handler")
        table.insert(self.chain, { type = "next", handler = handler })
        -- If we're already resolved, execute the chain from this new handler
        if self.state ~= "pending" then
          execute_chain(#self.chain, self.value)
        end
        return self
      end

      function promise:catch(handler)
        -- print("Adding catch handler")
        table.insert(self.chain, { type = "catch", handler = handler })
        if self.state == "rejected" then
          execute_chain(#self.chain, self.value)
        end
        return self
      end

      function promise:finally(handler)
        -- print("Adding finally handler")
        table.insert(self.chain, { type = "finally", handler = handler })
        if self.state ~= "pending" then
          execute_chain(#self.chain, self.value)
        end
        return self
      end

      -- print("About to call executor")
      local success, err = pcall(executor,
        function(value)
          -- print("Resolve called with:", value)
          if promise.state == "pending" then
            promise.state = "fulfilled"
            promise.value = value
            execute_chain(1, value)
          end
        end,
        function(reason)
          -- print("Reject called with:", reason)
          if promise.state == "pending" then
            promise.state = "rejected"
            promise.value = reason
            execute_chain(1, reason)
          end
        end
      )
      -- print("After executor call, success:", success, "err:", err)

      if not success then
        promise.state = "rejected"
        promise.value = err
        execute_chain(1, err)
      end

      return promise
    end
  end
})
