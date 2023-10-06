locals {
    nodemapping = {
        default= {
            autotermination_minutes = 20
        }
        bronze= {
            category= "General Purpose"
            autotermination_minutes = 20
            idle                    = false
        }
        silver= {
            category= "General Purpose"
            local_disk= true
            min_cores= 8
            min_memory_gb= 32
            fleet= false
            min_gpus= 1
        }
        ai-ml-fleet= {
            category= "GPU Accelerated"
            local_disk= true
            fleet= true
            min_gpus= 2
        }
    }
}