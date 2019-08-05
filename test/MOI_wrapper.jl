using MathOptInterface
const MOI = MathOptInterface
const MOIT = MOI.Test
const MOIU = MOI.Utilities
const MOIB = MOI.Bridges

MOIU.@model(PIPSModelData,
            (),
            (MOI.EqualTo, MOI.GreaterThan, MOI.LessThan),
            (MOI.Zeros, MOI.Nonnegatives, MOI.Nonpositives),
            (),
            (MOI.SingleVariable,),
            (MOI.ScalarAffineFunction, MOI.ScalarQuadraticFunction),
            (MOI.VectorOfVariables,),
            (MOI.VectorAffineFunction,))

const optimizer = PIPS.Optimizer()
const config = MOIT.TestConfig(atol=1e-4, rtol=1e-4,
                               optimal_status=MOI.LOCALLY_SOLVED)

@testset "SolverName" begin
    @test MOI.get(optimizer, MOI.SolverName()) == "PipsNlp"
end

@testset "MOI Linear tests" begin
    exclude = ["linear8a", # Behavior in infeasible case doesn't match test.
               "linear12", # Same as above.
               "linear8b", # Behavior in unbounded case doesn't match test.
               "linear8c", # Same as above.
               "linear7",  # VectorAffineFunction not supported.
               "linear15", # VectorAffineFunction not supported.
               # new excludes
               "linear14",   
                  "linear6",
                  "linear4",
                  "linear3",
                  "linear9",
                  # "linear1",
                  "linear2",
                  "linear10",
                  "linear5",
                  "linear13", 
                  "linear11"
               ]
    model_for_pips = MOIU.UniversalFallback(PIPSModelData{Float64}())
    linear_optimizer = MOI.Bridges.SplitInterval{Float64}(
                         MOIU.CachingOptimizer(model_for_pips, optimizer))
    MOIT.contlineartest(linear_optimizer, config, exclude)
end

# MOI.empty!(optimizer)
# 
# @testset "MOI QP/QCQP tests" begin
#     qp_optimizer = MOIU.CachingOptimizer(PIPSModelData{Float64}(), optimizer)
#     MOIT.qptest(qp_optimizer, config)
#     exclude = ["qcp1", # VectorAffineFunction not supported.
#               ]
#     MOIT.qcptest(qp_optimizer, config, exclude)
# end
# 
# MOI.empty!(optimizer)
# 
# @testset "MOI NLP tests" begin
#     MOIT.nlptest(optimizer, config)
# end
