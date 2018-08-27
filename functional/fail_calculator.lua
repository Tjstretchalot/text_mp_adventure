--- Calculates the probability of failure AND attributes it to
-- a specific probability
-- @module fail_calculator

local fail_calculator = {}

--- Determines if an action with the given probabilities
-- fails as a result of the given probabilities. The order
-- of the probabilities is important - if you get a 50%
-- chance to fail then a 20% chance to fail, stacking multiplicatively,
-- you have a net 60% chance to fail and you only fail (additively)
-- 10% more often from the 20%; however the other order gives you
-- a 20% chance to fail from that cause and a 40% chance (additive)
-- to fail.
--
-- Example of the inputs:
-- {
--   {
--     type: 'multiplicative',
--     chance: 0.50
--   },
--   {
--     type: 'additive',
--     chance: -0.10
--   },
--   {
--     type: 'multiplicative',
--     chance: 0.25
--   }
-- }
--
-- At the end of the list is always an "IMPLIED" chance to succeed that
-- is multiplicative and 100%.
--
-- Note that this particular method of rescaling requires precomputing
-- the odds of us getting to a particular node on the tree.
--
-- @tparam {table,...} ordered probabilities and types
-- @return boolean,nil|{number,...} if the result succeeded, followed by
--  the indexes in ordered_probs that caused us to swap between success and failure
function fail_calculator.calculate(ordered_probs)
  --[[
  The likelihood of us getting to a specific location in the path.

  We start at 100% likelihood that we are on the success path (this
  is not in the array), than we have some probability to go from success
  to failure at each step. We keep track of this in order to correctly
  rescale additive probabilities
  ]]
  local lSucc = 1
  local lFail = 0
  local current_result = true
  local swaps_induced = {}
  for k, prob in ipairs(ordered_probs) do

    if prob.type == 'multiplicative' then
      if prob.chance > 0 then
        -- Multiplicative likelihood of going from SUCCEED to FAIL
        if current_result and math.random() < prob.chance then
          current_result = not current_result
          table.insert(swaps_induced, k)
        end

        local netChanceToSwapSides = lSucc * prob.chance
        lFail = lFail + netChanceToSwapSides
        lSucc = lSucc - netChanceToSwapSides
      else
        -- Multiplicative likelihood of going from FAIL to SUCCEED
        if not current_result and math.random() < -prob.chance then
          current_result = not current_result
          table.insert(swaps_induced, k)
        end

        local netChanceToSwapSides = lFail * (-prob.chance)
        lFail = lFail - netChanceToSwapSides
        lSucc = lSucc + netChanceToSwapSides
      end
    elseif prob.type == 'additive' then
      if prob.chance > 0 then
        -- Additive likelihood of going from SUCCEED to FAIL
        local netChanceToSwapSides = math.floor(lSucc, prob.chance)

        if current_result then
          local scaledChanceToSwapSides = prob.chance / lSucc
          if math.random() < scaledChanceToSwapSides then
            current_result = not current_result
            table.insert(swaps_induced, k)
          end
        end

        lFail = lFail + netChanceToSwapSides
        lSucc = lSucc - netChanceToSwapSides
      else
        -- Additive likelihood of going from FAIL to SUCCEED
        local netChanceToSwapSides = math.floor(lFail, -prob.chance)

        if not current_result then
          local scaledChanceToSwapSides = (-prob.chance) / lFail
          if math.random() < scaledChanceToSwapSides then
            current_result = not current_result
            table.insert(swaps_induced, k)
          end
        end

        lFail = lFail - netChanceToSwapSides
        lSucc = lSucc + netChanceToSwapSides
      end
    else
      error(string.format('ordered_probs[%d].type = \'%s\'; expected \'multiplicative\' or \'additive\''), k, tostring(prob.type))
    end
  end

  return current_result, swaps_induced
end

return fail_calculator
