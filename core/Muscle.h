#ifndef __MASS_MUSCLE_H__
#define __MASS_MUSCLE_H__
#include "dart/dart.hpp"
#include "MuscleLimitConstraint.h"

namespace MASS
{
	struct Anchor
	{
		int num_related_bodies;

		std::vector<dart::dynamics::BodyNode *> bodynodes;
		std::vector<Eigen::Vector3d> local_positions;
		std::vector<double> weights;

		Anchor(std::vector<dart::dynamics::BodyNode *> bns, std::vector<Eigen::Vector3d> lps, std::vector<double> ws);
		Eigen::Vector3d GetPoint();
	};
	class Muscle
	{
	public:
		Muscle(std::string _name, double f0, double lm0, double lt0, double pen_angle, double lmax, double type1_fraction);
		void AddAnchor(const dart::dynamics::SkeletonPtr &skel, dart::dynamics::BodyNode *bn, const Eigen::Vector3d &glob_pos, int num_related_bodies);
		void AddAnchor(dart::dynamics::BodyNode *bn, const Eigen::Vector3d &glob_pos);
		const std::vector<Anchor *> &GetAnchors() { return mAnchors; }
		void Update();
		void ApplyForceToBody();

		double GetForce();
		double GetActiveForce() { return Getf_A() * activation; };

		double get_l() { return l_mt0 / l_mt0_original; }
		double get_f() { return f0 / f0_original; }

		double Getf_A();
		double Getf_p();
		double Getl_mt();
		double GetNormalizedLength();
		double GetRecommendedMinLength();

		std::vector<std::vector<double>> GetGraphData();

		void SetMuscle();
		const std::vector<Anchor *> &GetAnchors() const { return mAnchors; }
		void set_l_mt_max(double l_max) { l_mt_max = l_max; }

		Eigen::MatrixXd GetJacobianTranspose();
		Eigen::MatrixXd GetReducedJacobianTranspose();

		std::pair<Eigen::VectorXd, Eigen::VectorXd> GetForceJacobianAndPassive();

		int GetNumRelatedDofs() { return num_related_dofs; };

		Eigen::VectorXd GetRelatedJtA();
		Eigen::VectorXd GetRelatedJtp();

		std::vector<dart::dynamics::Joint *> GetRelatedJoints();
		std::vector<dart::dynamics::BodyNode *> GetRelatedBodyNodes();
		void ComputeJacobians();
		Eigen::VectorXd Getdl_dtheta();

		double GetLengthRatio() { return length / l_mt0; };

	public:
		std::string name;
		std::vector<Anchor *> mAnchors;
		int num_related_dofs;
		std::vector<int> related_dof_indices;

		std::vector<Eigen::Vector3d> mCachedAnchorPositions;
		std::vector<Eigen::MatrixXd> mCachedJs;

		void change_f(double ratio) { f0 = f0_original * ratio; }
		void change_l(double ratio) { l_mt0 = l_mt0_original * ratio; }

		double g(double _l_m);
		double g_t(double e_t);
		double g_pl(double _l_m);
		double g_al(double _l_m);

		double l_mt, l_mt_max;
		double l_m;
		double activation;

		double f0;

		double f0_original;
		double l_mt0_original;

		double l_mt0, l_m0, l_t0, length;

		double f_toe, e_toe, k_toe, k_lin, e_t0;
		double k_pe, e_mo;
		double gamma;
		bool selected;

		Eigen::VectorXd related_vec;
		Eigen::VectorXd GetRelatedVec() { return related_vec; }
		double GetForce0() { return f0; }

		double GetMass();
		double GetBHAR04_EnergyRate();
		double type1_fraction;

		double GetType1_Fraction() { return type1_fraction; }
		double Getdl_velocity();
		double l_min, l_max;
		double f_min, f_max;
	};

}
#endif
